# Target Architecture

```text
VPC 10.0.0.0/16
├── PUBLIC SUBNET 10.0.1.0/24
│   └── EC2 App / Portfolio
│       ├── IAM Role
│       └── S3 Storage
│
└── PRIVATE SUBNETS
    ├── 10.0.2.0/24
    └── 10.0.3.0/24
        └── RDS MySQL

Lambda Health Check
        │
        ▼
CloudWatch Logs / Alarms
```

The existing tools VPC and VPC peering remain in the Terraform configuration as supporting infrastructure.
