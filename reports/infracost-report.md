# Infracost Cost Estimation Report

**Generated:** July 8, 2026

This report presents the estimated monthly cost of the AWS infrastructure provisioned using Terraform for the YOLO Segmentation Demo project.

## Estimated Monthly Cost

| Resource | Detail | Monthly Quantity | Unit | Monthly Cost |
|----------|--------|-----------------:|------|-------------:|
| Application Load Balancer | ALB running time | 730 | hours | $19.71 |
| Application Load Balancer | Load Balancer Capacity Units | Depends on usage | LCU | $5.84 per LCU |
| EC2 Instance | t3.micro Linux/UNIX (On-Demand) | 730 | hours | $8.76 |
| EC2 Root Volume | General Purpose SSD (gp2) | 8 | GB | $0.95 |

## Overall Estimated Cost

| Category | Cost |
|----------|-----:|
| Baseline Monthly Cost | **$29.42** |
| Usage-based Cost | Depends on application traffic |
| Estimated Total | **$29.42 + usage charges** |

## Resource Summary

| Description | Count |
|-------------|------:|
| Total AWS Resources | 15 |
| Costed Resources | 2 |
| Free Resources | 13 |

## Notes

- Generated using **Infracost**.
- Pricing is based on AWS public pricing available on **July 8, 2026**.
- Load Balancer Capacity Unit (LCU) charges depend on actual application traffic.
- Estimates may vary depending on AWS region, usage patterns, pricing updates, and Free Tier eligibility.