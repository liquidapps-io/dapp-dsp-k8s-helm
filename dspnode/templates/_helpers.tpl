{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dapp-dsp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "dapp-dsp.fullname" -}}
{{- $name := include "dapp-dsp.name" . -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dapp-dsp.biosfullname" -}}
{{- printf "%s-bios" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dapp-dsp.nodeosfullname" -}}
{{- printf "%s-nodeos" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dapp-dsp.headlessService" -}}
{{- printf "%s-service" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dapp-dsp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
