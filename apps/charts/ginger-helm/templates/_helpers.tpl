{{- define "ginger.name" -}}
{{- default .Chart.Name .Values.nameOverride | truncate 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ginger.fullname" -}}
{{- $name := template "ginger.name" . -}}
{{- if hasKey .Values.global "namespace" -}}
{{- printf "%s-%s" .Values.global.namespace $name | truncate 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | truncate 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ginger.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | truncate 63 | trimSuffix "-" }}
{{ include "ginger.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "ginger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ginger.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
