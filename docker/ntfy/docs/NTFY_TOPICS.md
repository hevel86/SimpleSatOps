# Managing ntfy Topics and Access

This guide explains how to manually add a topic and grant access to a user on the ntfy instance.

## 1. List Existing Users and Access

To see a list of users and their current topic permissions, run:

```bash
docker exec ntfy ntfy user list
```

## 2. Grant Access to a Topic

To grant a user access to a specific topic, use the `ntfy access` command.

### Syntax
```bash
docker exec ntfy ntfy access [username] [topic] [permissions]
```

*   **username**: The user you want to grant access to (e.g., `ntfy_user`). Use `*` for anonymous users.
*   **topic**: The name of the topic (e.g., `prometheus`).
*   **permissions**: Can be `read`, `write`, `read-write`, or `none`.

### Example: Granting read-write access to the "prometheus" topic
```bash
docker exec ntfy ntfy access ntfy_user prometheus read-write
```

## 3. Verify Changes

Run the user list command again to ensure the permissions were applied correctly:

```bash
docker exec ntfy ntfy user list
```

## Common Commands

*   **Change Access**: Re-run the `ntfy access` command with the new permission.
*   **Remove Access**: Set the permission to `none`.
    ```bash
    docker exec ntfy ntfy access ntfy_user prometheus none
    ```
