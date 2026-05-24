# Azure Active Directory Lab — Terraform

## To Do

- Developer SKU does not require a dedicated subnet or public ip - correct this.
- Resolve comments referring to windows 11, using a standard server, not windows11.

A minimal, isolated Azure AD lab consisting of:

| Resource | SKU / Size | Notes |
| --- | --- | --- |
| Domain Controller | `Standard_B2s` (2 vCPU / 4 GB) | Windows Server 2022, static private IP |
| Workstation | `Standard_B2s` (2 vCPU / 4 GB) | Windows Server 2022, domain-joined, Hybrid Benefit |
| Azure Bastion | Developer SKU | Cheapest Bastion tier; no public IP on VMs |
| VNet | Single `/16` | DC + workstation in `/24` workload subnet |

## Prerequisites

- Azure CLI authenticated (`az login`)
- Terraform >= 1.5
- Contributor role on the target subscription

## Quick Start

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your passwords

terraform init
terraform plan
terraform apply
```

`apply` takes ~15–20 minutes. The DC promotion and reboot (~5 min) must complete
before the workstation domain-join extension runs.

## Connecting via Bastion

1. Open the Azure Portal → Virtual Machines → select `adlab-dc` or `adlab-ws`
2. Click **Connect → Bastion**
3. Enter `labadmin` and your password
4. No public IP or VPN needed

## Cost Estimate (australiaeast, pay-as-you-go)

| Resource | ~AUD/month (running 24/7) |
| --- | --- |
| 2× Standard_B2s (WS2022 + Hybrid Benefit) | ~$47 |
| Bastion Developer | ~$0 (no per-hour charge) |
| 2× StandardSSD 128 GB | ~$30 |
| Public IP (Bastion) | ~$5 |
| **Total** | **~$110/month** |

**Note:** Stop (deallocate) both VMs when not in use — you only pay for disks at
that point, dropping the cost to ~$35/month.

```bash
az vm deallocate --resource-group adlab-rg --name adlab-dc
az vm deallocate --resource-group adlab-rg --name adlab-ws
```

## Notes

- The VNet DNS is set to the DC's static private IP (`10.10.1.10` by default)
  so the workstation can resolve the domain during the join extension.
- The `DenyAllInbound` NSG rule means VMs are only reachable through Bastion.
- `corp.local` is used as the domain name. For a lab this is fine; avoid `.local`
  in production as it conflicts with mDNS.
- DSRM password is separate from the admin password — store it securely.
