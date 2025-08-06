**TASK**: Update Service Validation Audit Report.
**ROLE**: Senior Software Infrastructure Auditor.
**SCOPE**: Services Guide, Docker orchestration, Makefile, Devcontainer, Localstack, Health checks, Unified logging strategy, Unified scripts strategy, Temporal workflow, Monitoring.
**CONTEXT**: DICE development environment with distributed Docker orchestration, AWS emulation with Localstack, Temporal workflow, Unified logging strategy, Unified scripts strategy.
**REQUIREMENTS**:
- Get knowledge from `./KNOWLEDGE.md`.
- Validate all services, their implementation and related documentation.
**STEPS**:
- Start the entire stack using Docker orchestration (see `./infrastructure/docker/docker-compose.orchestrator.yml`).
- Start each service individually using Docker orchestration (see `./infrastructure/docker/docker-compose.orchestrator.yml`).
- Start the entire stack in debug mode using Docker orchestration (see `./infrastructure/docker/docker-compose.orchestrator.yml`).
- Start each service individually in debug mode using Docker orchestration and ensure that breakpoints work even in a container (see `./infrastructure/docker/docker-compose.orchestrator.yml`).
- Check the documentation related to Docker orchestration. Update or create if necessary (see `./infrastructure/docker/DOCKER_README.md`).
- Start the entire stack using Makefile (see `./Makefile`).
- Start each service individually using Makefile (see `./Makefile`).
- Check the documentation for Makefile. Update or create if necessary (see `./MAKEFILE_README.md`).
- Start the entire stack using Devcontainer (see `./.devcontainer/devcontainer.json`).
- Start each service individually using Devcontainer (see `./.devcontainer/devcontainer.json`).
- Check the documentation for Devcontainer. Update or create if necessary (see `./.devcontainer/DEVCONTAINER_README.md`).
- Start the entire stack using Localstack.
- Start each service individually using Localstack.
- Check the documentation for Localstack. Update or create if necessary (see `./infrastructure/localstack/LOCALSTACK_README.md`).
- Check that all services have a health check.
- Check the documentation relating to health checks. Update or create if necessary (see `./TESTING_TRACKER.md`).
- Check that all services are covered by unified logging.
- Check the documentation relating to unified logging. Update or create if necessary (see `./infrastructure/logging/LOGGING_README.md`).
- Check that all scripts are covered by unified scripts.
- Check the documentation relating to unified scripts. Update or create if necessary (see `./infrastructure/scripts/SCRIPTS_README.md`).
- Check that the Temporal workflow is correctly implemented and configured.
- Check the documentation relating to Temporal. Update or create if necessary (see `./infrastructure/temporal/TEMPORAL_README.md`).
**CONSTRAINTS**:
- If a bug is encountered, do not fix it. Instead, log the problem with the logs, stack trace and a simple action plan in an external file in Markdown format.
- Ensure British English compliance in the documentation.
**OUTPUT**: Create or update a Service Validation Audit Report file (`./SERVICE-AUDIT-REPORT.md`).
