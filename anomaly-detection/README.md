# Cost Anomaly Detection Module

## Overview

Creates an account-wide AWS Cost Anomaly Monitor and a daily email subscription.

## Resources Created

- AWS Cost Anomaly Monitor
- AWS Cost Anomaly Subscription

## Notifications

A notification is sent when the anomaly's total absolute impact meets or exceeds the configured USD threshold.

## Inputs

- `monitor_name`
- `subscription_name`
- `notification_email`
- `threshold_usd`

## Outputs

- `anomaly_monitor_arn`
- `anomaly_subscription_arn`
