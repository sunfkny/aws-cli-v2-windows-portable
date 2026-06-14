# aws-cli-v2-windows-portable

Portable build of AWS CLI v2 extracted from the official MSI package.

## Why

The official AWS CLI installer performs a machine-wide installation and can be noticeably slow, especially in automated environments, CI systems, containers, or when repeatedly provisioning development machines.

This portable package provides the AWS CLI files in a ready-to-use archive format, allowing extraction and use without running the official installer.
