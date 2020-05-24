{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nexus3.name" -}}
{{- default "nexus3" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nexus3.fullname" -}}
{{- $name := default "nexus3" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "nexus3.labels.standard" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ include "nexus3.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "nexus3.labels.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ include "nexus3.name" . }}"
{{- end -}}

{{- define "nexus3.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (not .Values.expose.tls.secretName) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}