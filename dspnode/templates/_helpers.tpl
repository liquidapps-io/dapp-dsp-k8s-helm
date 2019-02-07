{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dspnode.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "dspnode.fullname" -}}
{{- $name := include "dspnode.name" . -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dspnode.biosfullname" -}}
{{- printf "%s-bios" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dspnode.nodeosfullname" -}}
{{- printf "%s-nodeos" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dspnode.headlessService" -}}
{{- printf "%s-service" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dspnode.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
