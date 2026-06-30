# DSW Deployment Example

## :exclamation: Important

If you use or plan to use DSW, please let us know via [info@ds-wizard.org](mailto:info@ds-wizard.org) to:

- Join our [**Discord** server](https://discord.gg/MW3H9tdMcT), where you can be notified about important updates and releases + we can discuss your issues and ideas.
- Provide us feedback (what is good and bad, [feature requests](https://ideas.ds-wizard.org/), etc.)

This example is intended for **local setup and testing**. For production use there are many more things to do such as authentication, controlling exposed ports (e.g. do not expose ports of `postgres` and `garage`), data backups, or using proxy (with HTTPS and WebSocket enabled). As it is highly dependent on your use case, consult production deployment with your sysadmin or [contact us](https://ds-wizard.org/contact).

## Overview

This is an example deployment of the [Data Stewardship Wizard](https://ds-wizard.org) using [Docker Compose](https://docs.docker.com/compose/) and [Garage](https://garagehq.deuxfleurs.fr/) as the S3-compatible object storage.

It is intentionally set up as a **single-node local POC**:

- Garage runs in Docker on host ports `9000` (S3 API) and `9003` (Admin API)
- Garage UI runs on `127.0.0.1:8081`
- DSW points to `http://host.docker.internal:9000` so presigned URLs are reachable from the browser
- `create-bucket.sh` performs the one-time Garage bootstrap for this example

For information on how to use Data Stewardship Wizard, visit our [guide](https://guide.ds-wizard.org).

## Required Steps

These are the only steps needed to run the local example.

1. Create the local environment file:

   ```bash
   cp example.env .env
   ```

2. The tracked `config/application.yml` already contains demo application values for this example.

3. Start the stack:

   ```bash
   docker compose up -d
   ```

4. Bootstrap Garage:

   ```bash
   ./create-bucket.sh
   ```

5. Open DSW:

   [http://localhost:8080/wizard](http://localhost:8080/wizard/)

6. Log in with:

   - Email: `albert.einstein@example.com`
   - Password: `password`

## Optional

These steps are not required to start the example. They are only useful if you want to inspect the local Garage setup.

1. Open Garage UI:

   [http://localhost:8081](http://localhost:8081)

2. Log in to Garage UI with:

   - Username: `admin`
   - Password: `admin`

## What The Bootstrap Does

`create-bucket.sh` is intended to be safe to rerun for this local setup. It:

- assigns the single-node Garage layout if the node still has no role
- creates the configured S3 bucket if it does not exist
- imports the configured Garage access key if it does not exist
- grants read, write, and owner permissions on the bucket to that key

## Optional Verification

After setup, you can use this checklist to confirm the Garage-backed deployment works.

### Infrastructure checks

```bash
docker compose ps
docker compose logs garage --tail=100
docker compose logs garage-ui --tail=100
docker compose logs server --tail=100
docker compose logs docworker --tail=100
```

Expected results:

- `garage` is running
- `garage-ui` is running
- `server` creates the S3 client successfully
- `docworker` starts without S3 errors
- no authentication, signing, or region errors appear in the logs

### Application checks

In the DSW UI, verify:

1. the application opens and login works
2. a project file can be uploaded
3. the uploaded file can be downloaded
4. a document preview can be generated
5. a document template asset URL works, if applicable

In Garage UI, verify:

1. login works
2. the `engine-wizard` bucket is visible
3. file upload works
4. folder creation works

If these checks pass, Garage is functioning as a drop-in S3-compatible backend for this example deployment.

## Garage Notes

### Current Local Model

This repository uses Garage as a **local example only**. Our production setup still uses MinIO.

- DSW uses a single S3 bucket: `engine-wizard`
- Garage S3 API is available locally on `localhost:9000`
- Garage website endpoint is available locally on `localhost:9002`
- Garage UI is available locally on `localhost:8081`
- A local `plugin-proxy` service exposes plugin assets on `localhost:9004`

If you want to use locally stored plugin assets with this example, the plugin URL stored in DSW should point to the local proxy, for example:

```text
http://localhost:9004/plugins/<plugin-uuid>/<version>/
```

The actual plugin file must then be reachable at:

```text
http://localhost:9004/plugins/<plugin-uuid>/<version>/plugin.js
```

### Buckets And Plugins

Garage is S3-compatible, so the same bucket model you use with MinIO can also be used with Garage.

For this local example:

- DSW uses one shared bucket
- plugin assets can be exposed through the local `plugin-proxy`
- the plugin URL in the DSW database should point to the public plugin location, not to the Garage UI

If you use Garage in a self-hosted deployment, keep the same basic rule as with MinIO:

- private DSW data should stay private
- public plugins should live in a dedicated public location
- do not mix private application data and public plugin assets in the same public bucket

### Self-Hosted Security Note

If a self-hosted user wants to expose Garage outside localhost, they should not publish the raw Garage ports directly to the internet.

Instead, they should put Garage behind an HTTPS reverse proxy or another equivalent security layer that provides:

- TLS / HTTPS
- authentication for admin access
- controlled exposure of only the endpoints that should be public

In practice, that usually means:

- DSW stays behind its normal public HTTPS setup
- public plugin files are exposed through a dedicated public URL
- Garage admin or UI access is protected separately

This repository does not try to provide a full production Garage deployment. It only illustrates how Garage can be used locally in the deployment example.

## Important Notes

* Use `docker compose pull` to get newest image (hotfixes) before starting
* **Do not expose** PostgreSQL or raw Garage ports directly to the internet in a public deployment
* If you self-host Garage publicly, place it behind an HTTPS reverse proxy or another equivalent security layer and protect admin access
* When you want to use DSW publicly, **set up HTTPS proxy** (e.g. Nginx) with a certificate for your domain and change default accounts
* Set up volume mounted to PostgreSQL and Garage containers for persistent data
* Garage needs a one-time bootstrap after the stack starts. `create-bucket.sh` assigns the single-node layout, creates the bucket, imports the configured S3 key, and grants bucket permissions
* DSW uses `http://host.docker.internal:9000` as the S3 endpoint so both the DSW containers and the browser can reach the same local Garage endpoint
* Garage UI is configured with local basic auth defaults for this POC; change them before sharing the setup
* Always use **strong passwords** and never use default values, **change the demo secrets** in `config/application.yml` and `.env` before using this anywhere except local testing

## Troubleshooting

If something does not work:

```bash
docker compose ps
docker compose logs garage --tail=200
docker compose logs garage-ui --tail=200
docker compose logs server --tail=200
docker compose logs docworker --tail=200
```

Common local issues:

- Garage was started, but `create-bucket.sh` was not run yet
- Garage UI started, but Garage itself is not healthy yet
- `.env` values and the imported Garage key no longer match
- the server is still starting and has not reached a healthy state yet
- an old local data directory contains stale state from a previous attempt

## Security Audit

This repository is used to regularly check vulnerabilities in the latest release of Docker images. [Grype](https://github.com/anchore/grype) tool is used (see [security-audit.yml](.github/workflows/security-audit.yml) file and related GitHub Actions runs). Once a vulnerability is detected, we are notified and start working on a new hotfix version. You should **always use the latest version** you can find used in this repository.
