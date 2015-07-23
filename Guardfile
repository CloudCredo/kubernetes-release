clearing :on
directories %w(jobs templates)

manifest_path = 'manifest.yml'
guard :bosh, deployment_manifest: manifest_path do
  watch(/^jobs\/.*/)
  watch(manifest_path)
end

notification :tmux, display_message: true
