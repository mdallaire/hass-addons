# Home Assistant Add-ons Repository

This repository contains multiple Home Assistant add-ons. Each add-on is a self-contained Docker-based service that integrates with Home Assistant.

## Repository Structure

- **Root**: Contains repository metadata ([repository.json](../repository.json)) and shared CI/CD configuration
- **Add-on directories** (`waterfurnace/`, `weewx/`): Each contains a complete add-on with its own Dockerfile, config, and docs
- Each add-on follows the Home Assistant add-on standard structure with required files:
  - `config.yaml`: Add-on metadata, version, architecture support, options schema
  - `build.yaml`: Docker build configuration with base images and OCI labels
  - `Dockerfile`: Container build instructions
  - `entrypoint.sh`: Container startup script
  - `README.md`, `DOCS.md`, `CHANGELOG.md`: Documentation
  - `translations/`: Localization files (e.g., `en.yaml`) for configuration UI

## Add-on Architecture

### Waterfurnace Aurora
- **Purpose**: Interfaces with Waterfurnace geothermal heat pumps via serial connection
- **Key dependencies**: Ruby gem `waterfurnace_aurora` (installed via gem command)
- **Configuration**: Requires `tty` (serial device path) and optional `mqtt` connection string
- **Integration**: Uses MQTT for Home Assistant communication, auto-discovers internal MQTT service
- **Build**: amd64 only (aarch64 commented out in config)

### Weewx
- **Purpose**: Weather station data collection and publishing
- **Key dependencies**: Python package `weewx` (installed via pip)
- **Configuration**: Uses persistent storage via `addon_config` mapping for `weewx-data/`
- **Startup behavior**: Creates default config on first run if not exists, then starts `weewxd`
- **Build**: Multi-architecture (aarch64 and amd64)

## Version Management

### Renovate Bot
- Automatically updates dependencies using custom regex matchers
- Updates `_VERSION` environment variables in Dockerfiles when comments follow this pattern:
  ```dockerfile
  # renovate: datasource=<source> packageName=<name>
  ENV <NAME>_VERSION=<version>
  ```
- Example: `# renovate: datasource=rubygems packageName=waterfurnace_aurora`
- **Automatic version synchronization**: When a dependency version updates, Renovate automatically:
  - Updates the version in `config.yaml` to `v{newVersion}-1`
  - Adds a new changelog entry to `CHANGELOG.md`
  - All changes are committed to the same branch/PR via `postUpgradeTasks`

### Version Synchronization
- Add-on version in `config.yaml` should track upstream dependency version
- Format: `v<upstream_version>-<revision>` (e.g., `v1.5.7-1`)
- Increment revision number for addon-only changes without upstream updates

## CI/CD Workflows

### Builder Workflow
- **Trigger**: Push/PR to `main` branch
- **Smart building**: Only builds add-ons with changes to monitored files: `build.yaml config.yaml Dockerfile entrypoint.sh`
- **Matrix strategy**: Builds each changed add-on for all supported architectures
- **Test mode**: PRs build with `--test` flag (no registry push)
- **Registry**: Publishes to GitHub Container Registry (ghcr.io) on main branch pushes
- **Image naming**: `ghcr.io/mdallaire/{arch}-addon-<addon-name>` (uses `{arch}` placeholder in config.yaml)

### Lint Workflow
- Runs `frenck/action-addon-linter` on all add-ons
- Executes on push, PR, and daily schedule

## Development Conventions

### Add-on Configuration
- Use `bashio` helpers in entrypoint scripts for reading config: `bashio::config '<key>'`
- For MQTT integration: Check `bashio::services.available "mqtt"` before accessing
- MQTT auto-discovery: Use `bashio::services mqtt "host|port|username|password"` to get internal service details
- Schema validation: Define options schema in `config.yaml` with types (e.g., `"str"`, `"str?"` for optional)

### Docker Best Practices
- Use Alpine-based Home Assistant base images: `ghcr.io/home-assistant/{arch}-base:<version>`
- Clean up build dependencies: Install with `--virtual=.build-deps`, remove with `apk del --purge`
- Set Python environment variables for add-ons using pip:
  ```dockerfile
  ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_BREAK_SYSTEM_PACKAGES=1
  ```

### Entrypoint Scripts
- Export config values as environment variables using bashio
- Use `exec` for the main process to ensure proper signal handling
- Handle missing configuration gracefully with `bashio::exit.nok` for fatal errors

## Adding a New Add-on

1. Create a new directory at repository root with add-on slug name
2. Add required files: `config.yaml`, `build.yaml`, `Dockerfile`, `entrypoint.sh`, `README.md`, `DOCS.md`, `CHANGELOG.md`
3. In `config.yaml`:
   - Set unique slug and version
   - Define supported architectures
   - Configure image: `ghcr.io/mdallaire/{arch}-addon-<slug>`
   - Define options schema for user configuration
4. In `build.yaml`: Specify base images per architecture with renovate comments
5. Update root README.md to document the new add-on
6. CI automatically detects new add-on directories and includes them in builds

## Common Tasks

**Update add-on version**: Edit `version` in `config.yaml` + add entry to `CHANGELOG.md`

**Update upstream dependency**: Modify `ENV <NAME>_VERSION` in Dockerfile (Renovate will auto-update if properly annotated)

**Test locally**: Use Home Assistant builder:
```bash
docker run --rm --privileged -v $(pwd):/data homeassistant/amd64-builder --test --amd64 --target /data/<addon-dir> --addon
```

**Check architecture support**: Review `arch` list in `config.yaml` and architectures in `build.yaml`
