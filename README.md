# kubernetes-release

Deploy [Kubernetes](http://kubernetes.io) easily with this
[BOSH](http://docs.cloudfoundry.org/bosh/) release.

## Kubernetes on your laptop

* Install [BOSH Lite](https://github.com/cloudfoundry/bosh-lite) and
  boot the Vagrant VM.
* Deploy Kubernetes:

```
$ bosh upload stemcell https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/warden/bosh-stemcell-25-warden-boshlite-ubuntu-trusty-go_agent.tgz
$ git clone https://github.com/cloudcredo/kubernetes-release
$ cd kubernetes-release
$ bosh create release --force && bosh -n upload release
$ ./generate_deployment_manifest warden $(bosh status --uuid) > manifest.yml
$ bosh deployment manifest.yml
$ bosh -n deploy
```

## Running the Guestbook example

The release includes an errand to deploy the
[GuestBook example](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples/guestbook).
```
$ bosh run errand guestbook-example
```
