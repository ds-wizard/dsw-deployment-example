# DSW Deployment Example

## :exclamation: Important

If you use or plan to use DSW, please let us know via [info@ds-wizard.org](mailto:info@ds-wizard.org) to:

- Join our [**Discord** server](https://discord.gg/MW3H9tdMcT), where you can be notified about important updates and releases + we can discuss your issues and ideas.
- Provide us feedback (what is good and bad, [feature requests](https://ideas.ds-wizard.org/), etc.)

This example is intended for **local setup and testing**. For production use there are many more things to do such as authentication, controlling exposed ports (e.g. do not expose ports of `postgres` and `garage`), data backups, or using proxy (with HTTPS and WebSocket enabled). As it is highly dependent on your use case, consult production deployment with your sysadmin or [contact us](https://ds-wizard.org/contact).

## Overview

This is an example deployment of the [Data Stewardship Wizard](https://ds-wizard.org) using [Docker Compose](https://docs.docker.com/compose/) and [Garage](https://garagehq.deuxfleurs.fr/) as the S3-compatible object storage.

It is intentionally set up as a **single-node local POC**:

- Garage runs in Docker on `127.0.0.1:9000`
- DSW points to `http://host.docker.internal:9000` so presigned URLs are reachable from the browser
- `create-bucket.sh` performs the one-time Garage bootstrap for this example

For information on how to use Data Stewardship Wizard, visit our [guide](https://guide.ds-wizard.org).

## Quick Start

1. Create the local environment file:

   ```bash
   cp example.env .env
   ```

2. Start the stack:

   ```bash
   docker compose up -d
   ```

3. Bootstrap Garage:

   ```bash
   ./create-bucket.sh
   ```

4. Open DSW:

   [http://localhost:8080/wizard](http://localhost:8080/wizard/)

5. Log in with:

   - Email: `albert.einstein@example.com`
   - Password: `password`

## What The Bootstrap Does

`create-bucket.sh` is intended to be safe to rerun for this local setup. It:

- assigns the single-node Garage layout if the node still has no role
- creates the configured S3 bucket if it does not exist
- imports the configured Garage access key if it does not exist
- grants read, write, and owner permissions on the bucket to that key

## Verification Checklist

After setup, use this checklist to confirm the Garage-backed deployment works.

### Infrastructure checks

```bash
docker compose ps
docker compose logs garage --tail=100
docker compose logs server --tail=100
docker compose logs docworker --tail=100
```

Expected results:

- `garage` is running
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

If these checks pass, Garage is functioning as a drop-in S3-compatible backend for this example deployment.

## Important Notes

* Use `docker compose pull` to get newest image (hotfixes) before starting
* **Do not expose** PostgreSQL and Garage to the internet (Garage should be exposed only via proxy in public deployments)
* When you want to use DSW publicly, **set up HTTPS proxy** (e.g. Nginx) with a certificate for your domain and change default accounts
* Set up volume mounted to PostgreSQL and Garage containers for persistent data
* Garage needs a one-time bootstrap after the stack starts. `create-bucket.sh` assigns the single-node layout, creates the bucket, imports the configured S3 key, and grants bucket permissions
* DSW uses `http://host.docker.internal:9000` as the S3 endpoint so that presigned URLs returned by DSW are reachable from your browser in this local setup
* Always use **strong passwords** and never use default values, **change the secrets** in `config/application.yml` and `.env` (JWT secret, RSA private key, Garage RPC/admin tokens, and S3 credentials)

## Troubleshooting

If something does not work:

```bash
docker compose ps
docker compose logs garage --tail=200
docker compose logs server --tail=200
docker compose logs docworker --tail=200
```

Common local issues:

- Garage was started, but `create-bucket.sh` was not run yet
- `.env` values and the imported Garage key no longer match
- the server is still starting and has not reached a healthy state yet
- an old local data directory contains stale state from a previous attempt

## Security Audit

This repository is used to regularly check vulnerabilities in the latest release of Docker images. [Grype](https://github.com/anchore/grype) tool is used (see [security-audit.yml](.github/workflows/security-audit.yml) file and related GitHub Actions runs). Once a vulnerability is detected, we are notified and start working on a new hotfix version. You should **always use the latest version** you can find used in this repository.
