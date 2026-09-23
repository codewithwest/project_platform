# AX Agent Orchestration Integration Plan

## Status

**Planned / experimental** — AX is not yet a production dependency of the platform.

AX (Google's open agentic orchestration runtime) is intended to run as an **agent execution layer on top of the Dragonslur Kubernetes platform**, not replace the platform itself.

> AX is currently evolving and its core concepts/protocols may change before a stable release. The integration should therefore remain isolated and reversible.

## Architecture

```text
                    DRAGONSLUR PLATFORM
┌──────────────────────────────────────────────────────────────┐
│ Ubuntu bare metal                                            │
│ K3s cluster                                                  │
│                                                              │
│  Longhorn ───── persistent volumes                           │
│  CloudNativePG ─ PostgreSQL                                  │
│  Platform services / networking / observability              │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ AX Agent Execution Layer                               │  │
│  │                                                        │  │
│  │ Tasks ─ Workspaces ─ Gateways ─ Models                 │  │
│  │        │             │          │                      │  │
│  │        └─────────────┴──────────┴── Agent workloads    │  │
│  └────────────────────────────────────────────────────────┘  │
│                              ▲                               │
└──────────────────────────────┼───────────────────────────────┘
                               │
                         G.I.N.G.E.R.
                    Main Agent / Control Plane
                               │
             ┌─────────────────┴─────────────────┐
             │                                   │
      Tooling Control Center              Memory / Planning
             │
      Tools / MCP / Skills
``` 

## Responsibility split

### Dragonslur / Project Platform

Owns the underlying infrastructure:

- Bare-metal Ubuntu nodes
- K3s cluster lifecycle
- Networking and ingress
- Longhorn persistent storage
- CloudNativePG PostgreSQL
- Platform services
- Observability and infrastructure security
- Node/resource capacity

### AX

Owns autonomous agent execution:

- Isolated agent Tasks
- CPU and memory resource boundaries
- Task lifecycle: create, watch, suspend, resume, delete
- Agent execution environments
- Workspace preparation
- MCP/skill/Git workspace bindings
- Network boundaries through Gateways
- Centralized Model definitions
- Agent task trees and delegated workloads

### G.I.N.G.E.R.

Remains the higher-level intelligence and user-facing control plane:

- Conversation and intent classification
- Planning and decomposition
- Interaction Graph / persistent memory
- Selecting tools and capabilities
- Deciding when to delegate work to AX
- Collecting and interpreting agent results
- User interaction and voice/hologram UI
- Model routing through the existing model/LiteLLM stack

### Tooling Control Center

Becomes the management layer for agent capabilities:

- Tools
- MCP servers
- Skills
- Agent/workspace profiles
- Model profiles
- Permissions and network policies
- Tool health/version information
- Active AX Tasks
- Task history and results

## Why AX fits the platform

### 1. Safe autonomous execution

G.I.N.G.E.R. should not need unrestricted access to a Dragonslur node to perform autonomous work. AX Tasks can provide isolated execution environments with explicit CPU/memory limits.

Example workloads:

- Repository analysis
- Coding agents
- Test agents
- Research agents
- Documentation agents
- Data-processing agents
- Build/validation workers

### 2. Agent delegation

G.I.N.G.E.R. can remain the primary planner while AX executes delegated work.

```text
User request
     │
     ▼
G.I.N.G.E.R.
     │
     ├── simple request ───────────────► direct tool
     │
     └── complex task
              │
              ▼
          AX Task
              │
        ┌─────┼─────┐
        ▼     ▼     ▼
     research code  test
        │     │     │
        └─────┼─────┘
              ▼
        results → Ginger
```

### 3. Workspace-based capabilities

AX Workspaces provide a natural bridge to the Tooling Control Center. A workspace can define the Git repositories, MCP servers, skill registries, dependencies and goal available to an agent.

The platform should eventually maintain reusable workspace profiles such as:

- `ginger-coding`
- `ginger-research`
- `ginger-platform-admin`
- `ginger-docs`
- `ginger-testing`

### 4. Controlled network access

AX Gateways should be used to explicitly define agent network access.

For example, a coding task may be permitted to reach:

- GitHub
- approved package registries
- internal Git services
- approved MCP services
- approved model endpoints

Unnecessary outbound access should remain blocked.

### 5. Resource-aware execution

The Dragonslur cluster is resource constrained. AX Task resource requests/limits should therefore be part of the platform's agent policy rather than allowing agents to consume arbitrary node capacity.

Suggested policy concepts:

| Agent class | CPU | Memory | Purpose |
|---|---:|---:|---|
| lightweight | low | low | simple tools / inspection |
| standard | moderate | moderate | coding / research |
| heavy | high | high | builds / complex autonomous work |

Exact values will be determined from measured node capacity rather than hard-coded at this stage.

## Implementation phases

### Phase 0 — Architecture validation

- Keep existing Dragonslur K3s deployment unchanged.
- Confirm AX's current Kubernetes requirements.
- Validate compatibility with the cluster's K3s version.
- Document required CRDs, controllers, namespaces and dependencies.
- Do not migrate existing Ginger workloads yet.

### Phase 1 — Experimental AX deployment

Create a dedicated namespace:

```text
ax-system
```

Deploy AX separately from the existing platform services.

Initial validation should cover:

- AX controller startup
- CLI access
- Task creation
- Task execution
- Task resource limits
- Task suspend/resume
- Task deletion
- Workspace creation
- Gateway restrictions
- Model configuration

### Phase 2 — First Ginger-controlled Task

G.I.N.G.E.R. should gain a small AX adapter rather than embedding AX-specific logic throughout the framework.

Conceptually:

```text
Ginger AX Adapter
├── create_task()
├── get_task()
├── watch_task()
├── suspend_task()
├── resume_task()
├── delete_task()
└── collect_result()
```

The adapter should translate Ginger's internal task/delegation model into AX resources.

### Phase 3 — Tooling Control Center integration

Add AX-backed resources to the UI:

```text
Tooling Control Center
├── Tools
├── MCP Servers
├── Skills
├── Workspaces
├── Models
├── Agents
│   └── AX Task Templates
└── Active Tasks
```

The UI should expose lifecycle and policy information without requiring operators to use the AX CLI for normal management.

### Phase 4 — Agent delegation

Introduce controlled delegation from Ginger:

1. Ginger receives a complex request.
2. Planner determines that isolated execution is required.
3. Ginger selects an approved AX workspace.
4. Ginger creates an AX Task.
5. AX executes the agent workload.
6. Ginger watches task state.
7. Results are returned to Ginger.
8. Ginger validates/summarizes the result for the user.
9. Task is suspended or deleted according to policy.

### Phase 5 — Production hardening

Only after the experimental deployment is stable:

- Persistent task/result storage where required
- Authentication and authorization
- Network policy enforcement
- Resource quotas
- Observability and audit trails
- Failure/retry policies
- Backup and recovery considerations
- Multi-node scheduling validation
- Security review
- Upgrade/rollback procedure

## Model integration

The platform already has model routing infrastructure. AX should not become a second uncontrolled model-routing system.

Preferred direction:

```text
                    Model Routing
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
         LiteLLM                  Ollama
             │                       │
             └───────────┬───────────┘
                         ▼
                    AX Models
                         ▼
                    Agent Tasks
```

AX Model resources should reference approved model/provider configurations. Secrets should remain Kubernetes-managed and should not be embedded in agent workspace definitions.

## Storage and persistence

AX should use the existing Dragonslur storage architecture where persistence is required:

- **Longhorn** for persistent volumes
- **CloudNativePG** for PostgreSQL-backed platform data

Do not introduce a second general-purpose storage system solely for AX unless a concrete AX requirement makes it necessary.

## Security principles

1. Agents are untrusted workloads by default.
2. No unrestricted host access.
3. Least-privilege service accounts.
4. Explicit resource limits.
5. Explicit network egress.
6. Secrets are injected through Kubernetes mechanisms, not stored in repositories.
7. Workspace capabilities are allowlisted.
8. Destructive platform operations require separate authorization.
9. AX remains isolated while its APIs and behavior are still changing.

## Initial proof of concept

The first real-world test should be intentionally small:

> Ask G.I.N.G.E.R. to inspect the `project_platform` repository and produce a technical report without modifying the repository.

The AX Task should have:

- Read-only GitHub access
- A dedicated workspace
- Restricted network egress
- Limited CPU/memory
- No privileged Kubernetes access
- A defined timeout
- Result returned to G.I.N.G.E.R.

Success criteria:

- Task can be created by Ginger.
- Task executes in isolation.
- Resource limits are enforced.
- Network access matches the Gateway policy.
- Results can be collected reliably.
- Task can be cleaned up automatically.
- No existing Dragonslur services are disrupted.

## Current decision

**AX is planned as an experimental agent execution substrate for Dragonslur, not as a replacement for K3s or the platform architecture.**

The integration must remain modular so that the platform can continue operating if AX changes significantly or is ultimately not adopted.
