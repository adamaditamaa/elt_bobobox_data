from airflow import DAG
from datetime import datetime,timedelta
from airflow.models import  TaskInstance,Variable
from discord_webhook import DiscordWebhook, DiscordEmbed
from airflow.hooks.base_hook import BaseHook
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.operators.dummy import DummyOperator
from cosmos import ProfileConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping
from cosmos import DbtTaskGroup, ProjectConfig

import json
import re
import os
import warnings
warnings.filterwarnings("ignore")
        

# Notifications Discord
def send_discord_notification(context):
    ti: TaskInstance = context['task_instance']
    dag_name = ti.dag_id
    task_name = ti.task_id
    log_link = ti.log_url

    # Custom Link to our Expose Port
    new_ip = "0.0.0.0"
    new_port = "8081"
    new_url = log_link.replace("localhost:8080", f"{new_ip}:{new_port}")

    execution_date = context['execution_date']
    new_date = execution_date + timedelta(hours=7)
    formatted_new_date = new_date.strftime("%Y-%m-%d %H:%M:%S")

    # Properly handle the exception
    exception = context.get('exception')
    if exception:
        error_message = str(exception)  # Convert exception to string
    else:
        error_message = "Airflow - An unknown error occurred. | <@&1085774092923310080>"

    error_message = error_message[:1000] + ('...' if len(error_message) > 1000 else '')

    try:
        str_start = re.escape("{'reason': ")
        str_end = re.escape('"}.')
        match = re.search(f'{str_start}(.*){str_end}', error_message)
        if match:
            error_message = "{'reason': " + match.group(1) + '}'
        else:
            error_message = f"Airflow Error: {error_message} | <@&1085774092923310080>"
    except Exception as e:
        error_message = f"Airflow Error: {error_message} | <@&1085774092923310080>"
    
    webhook_url = BaseHook.get_connection('discord_webhook').password
    webhook = DiscordWebhook(url=webhook_url)

    embed = DiscordEmbed(title="Airflow Alert - Task has Failed!", color='CC0000', url=new_url)
    embed.add_embed_field(name="Timestamp", value=formatted_new_date)
    embed.add_embed_field(name="DAG", value=dag_name, inline=True)
    embed.add_embed_field(name="PRIORITY", value="HIGH", inline=True)
    embed.add_embed_field(name="TASK", value=task_name, inline=False)
    embed.add_embed_field(name="ERROR", value=error_message)
    webhook.add_embed(embed)

    response = webhook.execute()
    return response

def dbt_profile(profile_name,target_name,schema,target_id):
    profile_dbt = ProfileConfig(
        profile_name=profile_name,
        target_name=target_name,
        profile_mapping=PostgresUserPasswordProfileMapping(
            conn_id=target_id,
            profile_args={"schema": schema},
        )
    )
    return profile_dbt


# Variable Path
current_script_path = os.path.abspath(__file__)
main_folder = os.path.dirname(current_script_path)
folder_modeling = 'modeling'
folder_models = 'models'
DBT_PROJECT_PATH = os.path.join(main_folder,folder_modeling)

# Name Script
script_name = 'ELT Prod Bobobox'
dag_name = 'elt_prod_bobobox'
owner_script = 'Data Engineer'

# schedule
time_schedule = '5 18 * * *'

# Airbyte Config
airbyte_conn_airflow = 'airbyte_production'
timeout_airbyte = 36000
wait_airbyte = 3

# Schema define
schema_name_analytics = 'production'
CONNECTION_ID = 'dwh_bobobox'

# Variable Airflow
value_airflow = Variable.get("var_etl_bobobox")
value_dict = json.loads(value_airflow)
todays = value_dict['date']

try:
    date_object = (datetime.strptime(todays, '%Y-%m-%d'))
except:
    todays = ((datetime.now())+timedelta(hours=7)).strftime('%Y-%m-%d')

dbt_vars = {
    "conditional_format": value_dict['conditional_format'],
    "date_format":str(todays)
}

# DBT Profile
profile_name_stg = 'modeling'
target_name_stg = 'dev'
profile_config = dbt_profile(profile_name=profile_name_stg,target_name=target_name_stg,schema=schema_name_analytics,target_id=CONNECTION_ID)


# Defaul Args for DAG
default_args = {
    'owner': owner_script,
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
    'on_failure_callback': send_discord_notification 
}

# DAG Process
with DAG(
    dag_id=dag_name, 
    default_args=default_args, 
    catchup=False, 
    schedule_interval=time_schedule,
    ) as dag:

    start_trigger = DummyOperator(
        task_id='start_get_data',
        dag=dag
    )

    airbyte_execute = AirbyteTriggerSyncOperator(
        task_id=f'airbyte_bobobox',
        airbyte_conn_id=airbyte_conn_airflow,
        connection_id=Variable.get(f"var_airbyte_bobobox"),
        asynchronous=False,
        timeout=timeout_airbyte,
        wait_seconds=wait_airbyte,
        dag=dag,
    )

    transform_data = DbtTaskGroup(
        group_id="transform_data",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        operator_args={
            "vars": f'{dbt_vars}',
        },
        profile_config=profile_config,
    )

    
    start_trigger >> airbyte_execute >> transform_data