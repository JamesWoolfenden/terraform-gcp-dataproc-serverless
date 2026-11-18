# terraform-gcp-dataproc-serverless

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-dataproc-serverless/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-dataproc-serverless/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-dataproc-serverless.svg)](https://github.com/JamesWoolfenden/terraform-gcp-dataproc-serverless/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-dataproc-serverless.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-dataproc-serverless/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Dataproc Serverless (Serverless for Apache Spark). Runs a Spark batch with an explicit non-default service account, internal-only networking on a caller-supplied subnetwork (which must have Private Google Access), a CMEK key, a maximum TTL and a pinned runtime version, and optionally creates an interactive Jupyter session template with the same settings. The CMEK key is granted to both the Dataproc service agent and the Compute Engine service agent (which creates the workload disks), and the workload service account is granted `roles/dataproc.worker`.

## Usage

Add **module.dataproc_serverless.tf** to your code:-

```terraform
module "dataproc_serverless" {
  source          = "jameswoolfenden/dataproc-serverless/gcp"
  batch_id        = "example-sparkpi"
  region          = "europe-west2"
  kms_key_name    = google_kms_crypto_key.main.id
  subnetwork      = google_compute_subnetwork.workloads.self_link
  service_account = google_service_account.batch.email

  spark_batch = {
    main_class    = "org.apache.spark.examples.SparkPi"
    jar_file_uris = ["file:///usr/lib/spark/examples/jars/spark-examples.jar"]
    args          = ["1000"]
  }
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_dataproc_batch.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataproc_batch) | resource |
| [google_dataproc_session_template.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataproc_session_template) | resource |
| [google_kms_crypto_key_iam_member.compute_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.dataproc_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project_iam_member.batch_sa_worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_batch_id"></a> [batch\_id](#input\_batch\_id) | ID of the Dataproc Serverless batch (4-63 chars, lowercase letters, numbers and hyphens) | `string` | n/a | yes |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | CMEK key used to encrypt workload persistent disks and data; must be in the same region as the workload | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the batch and session template for cost allocation and ownership tracking | `map(string)` | `{}` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags applied to workload VMs, used to target firewall rules | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | Region the batch (and session template) run in | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Dataproc Serverless runtime version to pin to, so upgrades happen deliberately rather than by picking up GCP's default | `string` | `"2.2"` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Email of the service account the workload runs as; granted roles/dataproc.worker. Must not be the default Compute Engine SA | `string` | n/a | yes |
| <a name="input_session_template"></a> [session\_template](#input\_session\_template) | Optional interactive (Jupyter) session template sharing the batch's CMEK, network and service account settings. Null to create none | <pre>object({<br/>    name         = string<br/>    kernel       = optional(string, "PYTHON")<br/>    display\_name = optional(string)<br/>    idle\_ttl     = optional(string, "1800s")<br/>  })</pre> | `null` | no |
| <a name="input_spark_batch"></a> [spark\_batch](#input\_spark\_batch) | Spark batch definition: main class and the jars holding it | <pre>object({<br/>    main\_class    = string<br/>    jar\_file\_uris = list(string)<br/>    args          = optional(list(string), [])<br/>    file\_uris     = optional(list(string), [])<br/>    archive\_uris  = optional(list(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_spark_properties"></a> [spark\_properties](#input\_spark\_properties) | Spark properties applied to the workload runtime | `map(string)` | `{}` | no |
| <a name="input_staging_bucket"></a> [staging\_bucket](#input\_staging\_bucket) | Name of a GCS bucket for workload dependencies and config. Null lets Dataproc use its per-project default bucket | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Self-link or URI of the subnetwork the workload runs on. It must have Private Google Access enabled (workloads get internal IPs only) | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Maximum duration (e.g. "3600s") the workload may run before it is terminated | `string` | `"3600s"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | ID of the Dataproc Serverless batch |
| <a name="output_session_template_id"></a> [session\_template\_id](#output\_session\_template\_id) | ID of the session template, or null when none is created |
| <a name="output_state"></a> [state](#output\_state) | State of the batch at the time of the last refresh |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "dataproc.batches.create",
    "dataproc.batches.delete",
    "dataproc.batches.get",
    "dataproc.sessionTemplates.create",
    "dataproc.sessionTemplates.delete",
    "dataproc.sessionTemplates.get",
    "dataproc.sessionTemplates.update",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "dataproc.batches.get",
    "dataproc.sessionTemplates.get",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-dataproc-serverless/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-dataproc-serverless/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
