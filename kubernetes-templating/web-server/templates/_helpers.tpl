{{/*
Expand the name of the chart.
*/}}
{{- define "web-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "web-server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "web-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "web-server.labels" -}}
helm.sh/chart: {{ include "web-server.chart" . }}
{{ include "web-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "web-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "web-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "web-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name for ConfigMap
*/}}
{{- define "web-server.configMapName" -}}
{{- if .Values.configmap.name }}
{{- .Values.configmap.name }}
{{- else }}
{{- printf "%s-cm" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name for PVC
*/}}
{{- define "web-server.pvcName" -}}
{{- if .Values.pvc.name }}
{{- .Values.pvc.name }}
{{- else }}
{{- printf "%s-pvc" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name for Service
*/}}
{{- define "web-server.serviceName" -}}
{{- printf "%s" (include "web-server.fullname" .) }}
{{- end }}

{{/*
Create the name for Gateway
*/}}
{{- define "web-server.gatewayName" -}}
{{- printf "%s-gateway" (include "web-server.fullname" .) }}
{{- end }}

{{/*
Create the name for HTTPRoute
*/}}
{{- define "web-server.httpRouteName" -}}
{{- printf "%s-httproute" (include "web-server.fullname" .) }}
{{- end }}

{{/*
Create the name for ServiceAccount monitoring
*/}}
{{- define "web-server.monitoringServiceAccountName" -}}
{{- if .Values.serviceAccounts.monitoring.create }}
{{- .Values.serviceAccounts.monitoring.name }}
{{- else }}
{{- default "default" .Values.serviceAccounts.monitoring.name }}
{{- end }}
{{- end }}

{{/*
Create the name for ServiceAccount CD
*/}}
{{- define "web-server.cdServiceAccountName" -}}
{{- if .Values.serviceAccounts.cd.create }}
{{- .Values.serviceAccounts.cd.name }}
{{- else }}
{{- default "default" .Values.serviceAccounts.cd.name }}
{{- end }}
{{- end }}

{{/*
Create the name for StorageClass
*/}}
{{- define "web-server.storageClassName" -}}
{{- if .Values.storageClass.name }}
{{- .Values.storageClass.name }}
{{- else }}
{{- printf "%s-sc" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name for monitoring ClusterRole
*/}}
{{- define "web-server.monitoringClusterRoleName" -}}
{{- if .Values.rbac.monitoringClusterRole.name }}
{{- .Values.rbac.monitoringClusterRole.name }}
{{- else }}
{{- printf "%s-monitoring-cr" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name for monitoring ClusterRoleBinding
*/}}
{{- define "web-server.monitoringClusterRoleBindingName" -}}
{{- if .Values.rbac.monitoringClusterRoleBinding.name }}
{{- .Values.rbac.monitoringClusterRoleBinding.name }}
{{- else }}
{{- printf "%s-monitoring-crb" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name for CD RoleBinding
*/}}
{{- define "web-server.cdRoleBindingName" -}}
{{- if .Values.rbac.cdRoleBinding.name }}
{{- .Values.rbac.cdRoleBinding.name }}
{{- else }}
{{- printf "%s-cd-cr" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name for CD SA Secret
*/}}
{{- define "web-server.cdSaSecretName" -}}
{{- if .Values.secrets.cdSaSecret.name }}
{{- .Values.secrets.cdSaSecret.name }}
{{- else }}
{{- printf "%s-cd-sa-secret" (include "web-server.fullname" .) }}
{{- end }}
{{- end }}