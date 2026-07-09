# Infracost Cost Estimation Report

**Generated:** July 9, 2026

This report presents the estimated monthly cost of the AWS infrastructure provisioned using Terraform for the YOLO Segmentation Demo project.

## Estimated Monthly Cost

| Resource | Detail | Monthly Quantity | Unit | Monthly Cost |
|----------|--------|-----------------:|------|-------------:|
| **NAT Gateways (x2)** | NAT gateway running time | 1,460 | hours | $75.92 |
| **Application Load Balancer** | ALB running time | 730 | hours | $19.71 |
| **EC2 Instances (x2)** | t3.micro Linux/UNIX (On-Demand) | 1,460 | hours | $17.52 |
| **EC2 Root Volumes (x2)** | gp3 storage (20 GB each) | 40 | GB | $3.80 |
| **NAT Gateway Data** | Data processed by NAT gateway | Depends on usage | GB | $0.052 per GB |
| **Application Load Balancer LCU** | Load Balancer Capacity Units | Depends on usage | LCU | $5.84 per LCU |

## Overall Estimated Cost

| Category | Cost |
|----------|-----:|
| Baseline Monthly Cost | **$116.96** |
| Usage-based Cost | Depends on application traffic (Data processed, LCU) |
| **Estimated Total** | **$116.96 + usage charges** |

## Resource Summary

| Description | Count |
|-------------|------:|
| Total AWS Resources | 28 |
| Costed Resources | 7 |
| Free Resources | 21 |

## Notes

- Generated using **Infracost**.
- Pricing is based on AWS public pricing available on **July 9, 2026**.
- Estimates may vary depending on AWS region, usage patterns, pricing updates, and Free Tier eligibility.