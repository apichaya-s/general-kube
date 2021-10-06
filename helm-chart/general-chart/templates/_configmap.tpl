{{/*
Create configmap based on business unit
*/}}
{{- define "configmapTemplate" -}}
  {{- range $configmaps := .Values.configmap }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ tpl $configmaps.name $ }}
  namespace: {{ $.Release.Namespace }}
data:
    {{- range $mount := $configmaps.mount -}}
      {{- $fileList := $.Files.Glob $mount.localPath -}}
      {{- if $fileList -}}
        {{ ($fileList).AsConfig | nindent 2 }}
      {{- end -}}
    {{- end -}}
    {{- range $key, $val := $configmaps.key }}
      {{ $key  | nindent 2}}: {{ tpl $val $ | quote }}
    {{- end -}}
  {{- end }}
{{- end }}