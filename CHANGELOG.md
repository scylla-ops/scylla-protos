# Changelog

All notable changes to `scylla-protos` are in this file: the public API of Scylla.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). An entry marked
**Breaking** changes the API for a client.

## [Unreleased]

### Changed

- **Breaking:** the API of the new backend replaces the API of the old server. It keeps no
  compatibility, so the check of breaking changes is removed from the repository.
- Ids are opaque, in one message (`scylla.common.v1.Id`), and lists use keyset pages.

### Added

The services: `AccessService`, `AccountService`, `AgentService`, `AppService`, `CapabilityService`,
`InvitationService`, `JobService`, `NotificationService`, `PersonalTokenService`, `PipelineService`,
`ProfileService`, `ProjectService`, `RoleService`, `SecretService`, `SettingsService`, `TokenService`,
`TriggerService`, `UserAdminService`, `UserStateService` and `WorkspaceService`.

`GetCapabilities` gives `version` and `agent_image`, for the commands that install an agent.

**Access and accounts**

- `AccountService`: accounts, sessions, and a sign-in that waits for a person. A sign-in that waits
  keeps only the link with a password.
- Handles, instance admins, and a console of the users.
- Personal tokens, with a switch on the instance and a switch on each workspace.
- Permission checks, the list of the access to an object, and the error details for the clients.
- `UserStateService`: the state of the web app for the caller, as small JSON values with a version.

**Workspaces and roles**

- Workspaces with slugs and owners, and the management of the invitations.
- `RoleService`: custom roles, the roles of the instance, the provider of a role, and a required
  provider.
- `UpdateRole` takes an optional level. The level changes only while the role has no holder.
- The owner of a workspace is a role of `AccessService`. `AddOwner`, `RemoveOwner` and `ListOwners`
  are gone from `WorkspaceService`.
- The members, the effective access of a member, and the holders of a role.
- The limit of the workspaces in the settings of the instance.

**Notifications**

- `NotificationService`: the inbox of the caller, with a count, a list, read, unread, done and mark
  all as read.
- `AcceptInvitation` takes the token of the link or the id of the invitation. `DeclineInvitation`
  declines an invitation with its id, and tells the person that sent it.

**Projects and pipelines**

- The change of a project, and the encrypted secrets of a project.
- Pipelines, jobs and their run on the agents.
- The places of the nodes on the canvas: `SavePipelineLayout`, and a `layout` field in `GetPipeline`,
  `CreatePipeline` and `UpdatePipeline`.
- Cron and webhook triggers.

**Apps and agents**

- Apps with join codes and keys, and the stream of the agents.
- A disable and an enable of an App. Keys have names, and record their last use.
- The API tokens of the Apps and their limits, and the CI identities.
- The number of jobs that each agent holds, and its job stats.
- `GetAgentStatsRequest` takes an optional period (`from`, `to`). With no period, the stats stay the
  last 30 days.
- `Member` and `RoleHolderEntry` have `runner`. It is true for an app that runs jobs (an agent), so
  a client can tell an agent from another app.
- The contract of the GitHub and GitLab integration: the services of `scylla.integrations.v1` and
  `VcsAppService`, the source, the approval and the checkout of a job, the pipeline files, the push,
  pull request and tag triggers, and the checkout in a dispatch.
- `ListConnectionRepositoriesRequest` has an optional `workspace_id`. It replaces `project_id` to
  list the repositories of a connection for a project that does not exist yet.
- `Workspace.time_zone`: the IANA time zone of a workspace, `UTC` for a new workspace.
  `UpdateWorkspace` changes it with `time_zone`, and a name that is not an IANA name gives
  `INVALID_ARGUMENT` on `time_zone`.
- `PipelineService.ListPipelineSummaries` gives the dashboard the pipelines of a workspace that the
  caller can see, with their recent jobs, their health and their triggers. New messages
  `PipelineSummary`, `RecentJob` and `NextFire`, and new enums `PipelineSummaryOrder` and
  `TriggerKind`.
- `Job.origin` (`JobOrigin`) tells what started a job. `JobFilter` filters on the states, the
  origins and a range of the time of creation. `ListWorkspaceJobs` filters on projects and
  pipelines, and the view `JOB_VIEW_SUMMARY` gives the jobs with no nodes. `NodeRun.max_attempts`
  gives the most attempts of a node, and `waiting_reason` can be `NO_AGENT_WITH_CONTAINER`.
- `JobService.GetJobStats` gives the dashboard the figures of the jobs of a workspace that the
  caller can see for a period: the counts by end, the durations, the waits for an agent and the run
  time, with buckets of hours, days or weeks in the time zone of the workspace, groups by project,
  pipeline, agent or origin, and the previous period. New messages `JobFigures`, `JobBucket` and
  `JobGroup`, and new enums `JobStatsBucket`, `JobStatsGroup` and `JobStatsOrder`. `JobOutcomes`
  moves from `scylla.agents.v1` to `scylla.pipelines.v1`, with the same fields.
- `DashboardService` keeps the saved layouts of the dashboard of a workspace: list, get, create,
  change at the version that the client read, delete, and the team default of the workspace.
- `AgentService.GetSlotUsage` gives the busy job slots of the agents of a workspace and the slots of
  the connected agents. `GetAgentMetrics` gives the CPU use and the used memory of the machine of an
  agent, in buckets. The agent sends `Metrics` at the interval of
  `Welcome.metrics_interval_seconds`. `Host.started_at` tells the start of the agent, and
  `App.last_sample` gives its last sample.
- `TriggerService` has `ListWorkspaceTriggers`, `ListTriggerFires` and `GetTriggerFireStats`: the
  triggers of a workspace with their next fires, the history of their fires and of the missed cron
  times, and their counts. `FireStatus` has `FIRE_STATUS_MISSED`. A cron schedule uses the time zone
  of the workspace.
- `VcsConnectionService` has `GetDeliveryStats`: the counts of the webhook deliveries of a workspace
  for a period, for each connection with its newest delivery, for each webhook trigger, and by hour,
  day or week in the time zone of the workspace.
- `DashboardService.ListAttentionItems` gives the open items of a workspace that need a person
  ("Needs you"), newest first, with the counts of each kind and the items that are new since the
  last visit. New messages `AttentionItem`, `AttentionJob`, `AttentionNode`, `AttentionFire`,
  `AttentionAgent` and `AttentionCount`, and the new enum `AttentionKind`.

### Removed

- **Breaking:** `RepositoryLink.report_mode` and `UpdateRepositoryLinkRequest.report_mode` are
  removed. The provider sets the mode of a report: a check run on GitHub, a commit status on GitLab.

### Fixed

- An invitation keeps the rule of the escalation: the text of the API now says so.
- A role of the instance is not in the people of a workspace or of a project: `ListMembers` and
  `GetMemberAccess` now say so. The wire format did not change.
- The comments of the Git integration RPCs and messages give the error codes, the states and the
  reasons that the server gives, for example on RunPipeline, RerunJob, CreateTrigger and
  RepositoryLink.state_reason.
