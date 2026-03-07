# Metrics & Observability

## Metric Naming
- **Use tagged metrics** with status/result instead of separate metric names per outcome
  - ✅ `emit_metric("webhook.event.processing", %{status: :error})`
  - ✅ `emit_metric("webhook.job.validation", %{partner: id, status: :success})`
  - ❌ `emit_metric("webhook.event.processing_error")`
  - ❌ `emit_metric("webhook.job.validation_error")`

### Good: Tagged Metrics with Status
```elixir
if changeset.valid? do
  emit_metric("webhook.job.validation", %{partner: id, status: :success})
  [changeset]
else
  emit_metric("webhook.job.validation", %{partner: id, status: :error})
  []
end
```

## Metric Emission
- **Simple signature without defaults**
  ```elixir
  defp emit_metric(metric_name, tags) do
    Metrics.increment(metric_name, 1, tags)
  end
  ```

## Logging
- **Inline simple logging calls** rather than creating helper functions
  - ✅ Direct `Logger.error("message", metadata)` at call site
  - ❌ `defp log_error(event, reason)` wrapper for simple cases

### Good: Inline Logging with Context
```elixir
Logger.error("Invalid webhook job for endpoint",
  location_partner_id: endpoint.location_partner_id,
  errors: inspect(changeset.errors)
)
```
