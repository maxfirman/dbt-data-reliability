{{
  config(
    materialized = 'view',
    bind=False
  )
}}

with dbt_run_results as (
    select * from {{ ref('dbt_run_results') }}
),

dbt_snapshots as (
    select * from {{ ref('dbt_snapshots') }}
)

SELECT
    dbt_run_results.model_execution_id,
    dbt_run_results.unique_id,
    dbt_run_results.invocation_id,
    dbt_run_results.query_id,
    dbt_run_results.name,
    dbt_run_results.generated_at,
    dbt_run_results.status,
    dbt_run_results.full_refresh,
    dbt_run_results.message,
    dbt_run_results.execution_time,
    dbt_run_results.execute_started_at,
    dbt_run_results.execute_completed_at,
    dbt_run_results.compile_started_at,
    dbt_run_results.compile_completed_at,
    dbt_run_results.compiled_code,
    dbt_run_results.thread_id,
    dbt_snapshots.database_name,
    dbt_snapshots.schema_name,
    coalesce(dbt_run_results.materialization, dbt_snapshots.materialization) as materialization,
    dbt_snapshots.tags,
    dbt_snapshots.package_name,
    dbt_snapshots.path,
    dbt_snapshots.original_path,
    dbt_snapshots.owner,
    dbt_snapshots.alias
FROM dbt_run_results
JOIN dbt_snapshots ON dbt_run_results.unique_id = dbt_snapshots.unique_id
