# Delayed Job configuration
#
# @see https://github.com/collectiveidea/delayed_job

# `cf stop` on Cloud Foundry sends SIGTERM to processes.
# Requeue the job when this occurs.
Delayed::Worker.raise_signal_exceptions = :term

Delayed::Worker.queue_attributes = [
  { name: :high_priority, priority: -10 },
  { name: :low_priority, priority: 10 }
]
