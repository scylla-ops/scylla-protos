# Changelog

All notable changes to `scylla-protos` are in this file: the public API of Scylla.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). An entry marked
**Breaking** changes the API for a client.

## [Unreleased]

### Added

- The mail relay of an instance, set at runtime. `MailSettingsService` (`scylla.platform.v1`):
  `GetMailSettings` gives the relay of the instance (`MailRelay`: host, port, `MailSecurity` TLS,
  STARTTLS or none, user name, `password_set`, sender address and name) and `default_host`, the
  host of the default relay of the server (`SCYLLA_SMTP_URL`). `UpdateMailSettings` sets the whole
  relay. The password is write-only: an unset `password` keeps the saved one, and a new password on
  a server with no key of the secrets gives `SECRET_KEY_MISSING`. `ResetMailSettings` removes the
  relay, and the server uses its default again. `SendTestMail` sends a test mail at once and gives
  the answer of the relay or its error in `SendTestMailResponse` (`MAIL_RELAY_MISSING` when the
  server has no relay). The route permissions are `get_mail_settings`, `update_mail_settings`,
  `reset_mail_settings` and `send_test_mail`.
- Custom project icons. `Project.icon` gives the icon of a project (`scylla.common.v1.Icon`: a glyph
  of the web icon set with its color, or the id of an uploaded image). `UpdateProjectRequest.icon`
  (`IconChange`) sets a glyph, sends the bytes of a PNG, JPEG or WebP image, or resets the icon to
  the default when it has no kind.
- Search, order and health for a list of projects. `ListProjectsRequest` has `query` (the name, the
  description, the repository and the pipeline names), `order` (`ProjectOrder`: position, name, last
  job, failed first) and `health` (`ProjectHealth`: all, failed, running).
  `ListProjectsResponse.counts` (`ProjectCounts`) gives the count of the projects that the search
  finds, of the failing and the running ones, and of their pipelines.
  `RepositoryService.ListRepositoryLinks` gives the repository links of a workspace, or of at most
  100 projects, in one call (route permission `list_repository_links`).
- A photo for a user and an icon for an App. `User.avatar` and `Member.avatar`
  (`scylla.common.v1.Avatar`) give the uploaded image of a user or the color of the initials.
  `UpdateProfileRequest.avatar_image` sets the image (empty bytes remove it), and `avatar_color`
  sets the color (an empty text gives the main color). `App.icon` and `Member.icon` give the icon of
  an App. `AppService.SetAppIcon` sets a glyph with its color, an image, or the default icon (route
  permission `set_app_icon`).
- Groups of projects in a workspace. `Project.group_id` gives the group of a project.
  `ProjectGroupService` lists, creates, renames, reorders and deletes the groups of a workspace
  (`ListProjectGroups`, `CreateProjectGroup`, `UpdateProjectGroup`, `DeleteProjectGroup`), and
  `MoveProject` puts a project in a group or in no group, before another project or last.
  `ListProjectsRequest` has `section` (`ProjectSection`: the projects of one group, or the projects
  with no group) and `project_ids` (at most 100 projects). The order `PROJECT_ORDER_POSITION` uses
  the order of the groups and the place of each project in its group.
- Workspace icons and group folder colors. `Workspace.icon` gives the icon of a workspace
  (`scylla.common.v1.Icon`), and `UpdateWorkspaceRequest.icon` changes it. `ProjectGroup.color`
  gives the folder color of a group (a theme color or `#rrggbb`, empty for the default folder);
  `CreateProjectGroupRequest.color` and `UpdateProjectGroupRequest.color` set it.
- `RoleHolderEntry` has `avatar` (the avatar that a user chose: a photo or the color of the
  initials) and `icon` (the custom icon of an app), so that a list of role holders shows each actor
  as everywhere else.

### Fixed

- WorkspaceService: the new RPC `ListAllWorkspaces` (search, order, `others_only`, page, total),
  `WorkspaceDetails` and `WorkspaceOwner`, `details` in `GetWorkspaceResponse` and
  `ListWorkspacesResponse`, and `only_with_role` in `ListWorkspacesRequest`. Only new fields.

## [0.7.2] - 2026-11-25

### Added

- Scylla pipelines next to file pipelines. A project that takes its pipelines from the files of its
  repository keeps its editor pipelines, and `CreatePipeline` makes one there. `Pipeline` has `key`
  (the key of its report, which an editor pipeline and a file pipeline of a project share) and
  `key_taken_at`: a file of the default branch that takes the key of an editor pipeline wins, and
  the editor pipeline sends no report (`KEY_TAKEN` in `JobReports.no_report_reason`). A name whose
  key a file pipeline has gives `PIPELINE_KEY_TAKEN`. `PipelineSummary` has `source` and
  `key_taken`, and `MergeBlock` has `pipeline_source`: in such a project, a new merge rule for an
  editor pipeline gives `MERGE_BLOCK_FILE_ONLY`.
- Git events for an editor pipeline in such a project. `PipelineService.SetPipelineGitEvents` lets
  the admins of a workspace allow or stop its push, pull request and tag triggers (route permission
  `set_pipeline_git_events`), with `Pipeline.git_events_allowed_at` and `git_events_allowed_by`.
  Until then, `TriggerService` refuses such a trigger with `GIT_EVENTS_NOT_ALLOWED`.
- `AccountService.ResendVerificationEmail` sends a new link to verify the email of an account that
  waits for its check, with the same answer for each email. `ListSignInMethodsResponse.mail_sender`
  gives the address that the mails of the server come from.

### Changed

- `SignUp` with an email whose account waits for its check sends a new verify link, and the account
  does not change. `SetPipelineSource` to the files keeps the editor pipelines: they are no longer
  archived.

## [0.7.1] - 2026-11-24

### Added

- Agent labels. `AppService.SetAppLabels` replaces the labels that the admins of a workspace
  give to an App, and `App` has `labels` and `automatic_labels` (from the host of its agent). A
  pipeline and a pipeline file have `agent` (`AgentSettings`, with `labels`), and a job keeps
  them in `agent_labels`: the job goes only to an agent with each label. A pending job that
  waits for such an agent gives the reason `NO_AGENT_WITH_LABELS`.

## [0.7.0] - 2026-11-24

The API of the new backend. It replaces the API of the 0.6 server, with no compatibility.

### Added

- The common messages: an id is opaque, in one message (`scylla.common.v1.Id`), and a list uses
  keyset pages (`PageRequest`, `PageResponse`).
- Accounts and access: `AccountService` (accounts, sessions, and a sign-in that waits for a
  person), `TokenService`, `ProfileService`, `PersonalTokenService` (with a switch on the instance
  and on each workspace), `UserAdminService` (the instance admins and a console of the users) and
  `UserStateService` (the state of the web app for the caller, as small JSON values with a
  version). `AccessService` gives and lists the roles of an object, checks the permissions of the
  caller (`CheckPermissions`), and gives error details to the clients.
- Workspaces and roles: `WorkspaceService` (slugs, the IANA time zone of a workspace, and the limit
  of the workspaces of the instance), `InvitationService` and `RoleService` (custom roles, the roles
  of the instance, and a level that changes only while the role has no holder). The owners of a
  workspace hold the built-in role Workspace owner of `AccessService`. The members, the effective
  access of a member and the holders of a role, with `runner` for an app that runs jobs.
- Notifications and activity: `NotificationService` (the inbox of the caller, with a count, read,
  unread, done and mark all as read), `AcceptInvitation` and `DeclineInvitation`, and
  `ActivityService.ListActivity` (the activity feed of a workspace).
- Projects: `ProjectService`, and `SecretService` for the encrypted secrets of a project.
- Pipelines and jobs: `PipelineService` and `JobService`, the places of the nodes on the canvas
  (`SavePipelineLayout`, `layout`), the origin of a job (`JobOrigin`), the job filters, the
  summaries of the pipelines for the dashboard (`ListPipelineSummaries`), and the figures of the
  jobs of a workspace (`GetJobStats`).
- Conditional nodes: a `Need` has a node and a port, a `Switch` opens the ports of its cases, a
  `Merge` joins branches, and the port `error` of a run node takes its failure. `NodeRun.ports` and
  `JobEvent.ports` give the ports that a switch opened. In `agents/v1` the change is additive:
  `DispatchNode.links` has the needs with their ports, and `Hello.conditional_nodes` tells that an
  agent runs them. `ExportPipeline` refuses a pipeline with conditional nodes (`CONDITIONAL_NODES`).
- The library of a workspace: `FragmentService` keeps fragments (groups of nodes that the pipelines
  of a workspace share), their versions that never change, and the favorites of each reader. A
  pipeline links the version of a fragment (`Pipeline.fragment_links`), and a fragment can come
  from a package of a registry (`FragmentOrigin`).
- Triggers: `TriggerService` has cron and webhook triggers, the conditions of a webhook, the push,
  pull request and tag triggers, and the history of the fires (`ListWorkspaceTriggers`,
  `ListTriggerFires`, `GetTriggerFireStats`), with the missed and the skipped fires.
- Apps and agents: `AppService` (apps with join codes and named keys, a disable and an enable, API
  tokens with limits, and CI identities) and `AgentService` (the stream of the agents, their job
  stats for a period, `GetSlotUsage` and `GetAgentMetrics`). An agent sends its protocol, its build
  and `Metrics`. `App.compatibility` and `App.missing_features` tell how an agent fits the server,
  and `Job.unfit_agents` names the online agents that cannot get the code of a waiting job.
  `CapabilityService.GetCapabilities` gives the version of the server, its agent protocols and the
  image of the agent.
- The GitHub and GitLab integration: `VcsAppService`, and `VcsConnectionService`,
  `RepositoryService`, `MergeBlockService` and `VcsReportService` of `scylla.integrations.v1`. They
  have the connections, the repository links, the pipeline files, the source, the approval and the
  checkout of a job, the reports, the merge blocks and the counts of the webhook deliveries
  (`GetDeliveryStats`).
- The dashboard: `DashboardService` keeps the saved layouts of a workspace and its team default, and
  `ListAttentionItems` gives the open items that need a person ("Needs you").
- Legal and privacy: `LegalService` (the operator, the privacy contact and the legal documents, with
  what changes in a version), `ProfileService.ExportAccountData`, the acceptance of the terms of
  service (`AcceptTerms`, `GetMe.terms_acceptance_required`, `TERMS_NOT_ACCEPTED`), and
  `ConsentService.RecordConsent` for a choice about cookies.
- `SettingsService`: the settings of the instance.

### Changed

- **Breaking:** the API of the new backend replaces the API of the 0.6 server. It keeps no
  compatibility, so the check of breaking changes is removed from the repository.

[Unreleased]: https://github.com/scylla-ops/scylla-protos/compare/v0.7.2...HEAD
[0.7.2]: https://github.com/scylla-ops/scylla-protos/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/scylla-ops/scylla-protos/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/scylla-ops/scylla-protos/releases/tag/v0.7.0
