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
`InvitationService`, `JobService`, `PersonalTokenService`, `PipelineService`, `ProfileService`,
`ProjectService`, `RoleService`, `SecretService`, `SettingsService`, `TokenService`, `TriggerService`,
`UserAdminService` and `WorkspaceService`.

`GetCapabilities` gives `version` and `agent_image`, for the commands that install an agent.

**Access and accounts**

- `AccountService`: accounts, sessions, and a sign-in that waits for a person. A sign-in that waits
  keeps only the link with a password.
- Handles, instance admins, and a console of the users.
- Personal tokens, with a switch on the instance and a switch on each workspace.
- Permission checks, the list of the access to an object, and the error details for the clients.

**Workspaces and roles**

- Workspaces with slugs and owners, and the management of the invitations.
- `RoleService`: custom roles, the roles of the instance, the provider of a role, and a required
  provider.
- The members, the effective access of a member, and the holders of a role.
- The limit of the workspaces in the settings of the instance.

**Projects and pipelines**

- The change of a project, and the encrypted secrets of a project.
- Pipelines, jobs and their run on the agents.
- Cron and webhook triggers.

**Apps and agents**

- Apps with join codes and keys, and the stream of the agents.
- A disable and an enable of an App. Keys have names, and record their last use.
- The API tokens of the Apps and their limits, and the CI identities.
- The number of jobs that each agent holds, and its job stats.

### Fixed

- An invitation keeps the rule of the escalation: the text of the API now says so.
- A role of the instance is not in the people of a workspace or of a project: `ListMembers` and
  `GetMemberAccess` now say so. The wire format did not change.
