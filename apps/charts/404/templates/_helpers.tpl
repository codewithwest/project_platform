{{/*
Expand the name of the chart.
*/}}
{{- define "custom-error-pages.name" -}}
{{- "error-404" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Hardcoded to avoid DNS-1035 errors when release name starts with a number.
*/}}
{{- define "custom-error-pages.fullname" -}}
{{- "error-404" }}
{{- end }}
