{{/*
Create secret based
*/}}
{{- define "secretTemplate" -}}
  {{- range $secret := .Values.secret }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ tpl $secret.name $ }}
  namespace: {{ $.Release.Namespace }}
type: Opaque
data:
    {{- range $mount := $secret.mount -}}
      {{- $fileList := $.Files.Glob $mount.localPath -}}
      {{- if $fileList -}}
        {{ ($fileList).AsSecrets | nindent 2 }}
      {{- end -}}
    {{- end -}}
    {{- range $key, $val := $secret.key }}
      {{ $key  | nindent 2}}: {{ tpl $val $ | quote }}
    {{- end -}}
  {{- end }}
{{- end }}