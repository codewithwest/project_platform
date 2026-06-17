{{- define "litellm-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "litellm-proxy.fullname" -}}
{{- $name := include "litellm-proxy.name" . }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "litellm-proxy.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "litellm-proxy.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "litellm-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "litellm-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
