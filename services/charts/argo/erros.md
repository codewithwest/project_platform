# Deployment Errors resolutions

### fix secrets error, run the following command

### Unable to create application: application spec for jenkins is invalid: InvalidSpecError: application destination server 'https://kubernetes.default.svc' and namespace 'management' do not match any of the allowed destinations in project 'management'

This error indicates that the Argo CD project named management does not permit applications to be deployed to the management namespace on the cluster https://kubernetes.default.svc.
This is a security feature of Argo CD's AppProjects, which restrict where applications can be deployed. You need to explicitly configure your Argo CD AppProject to allow the destination you are using.

### How to fix it

### Method 1: Use the Argo CD UI (Easiest)

- Log in to your Argo CD UI.
- Navigate to Settings > Projects.
- Click on the management project to edit it.
- Find the Destinations section.
- Add a new destination with the following details:
- Server: https://kubernetes.default.svc
- Namespace: management
- Save the changes.
