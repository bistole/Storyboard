NOW
===


TODO
====

- Change layout of home page
  - Left panel to separate photo and task
  - Change to Grid for photos

- 


- Write doc:
  - [M] Deploy to TestFlight.
  - [M] Deploy to Google Play Console.

- Deployment enhancement
  - [L] Use appbundle instead of apk
  - [L] Need to test crash from kotlin
  - [L] Also can display logs from golang/backend
  - [L] Windows deployment 
  - [L] Windows crash report

- Backend enhancement
  - [L] Should have warning bar when can not connect server
  - [L] Split storage by environment
  - [L] Share backend/frontend media data on desktop
  - [L] Allow change PORT of backend service
  - [L] Change Windows Folder from /ProgramData/com.laterhorse.storyboard
    to /ProgramData/Laterhorse/Storyboard

- Overall UI
  - [M] Change icon for app.
  - [M] Hide UI and run as a service (icon shows on system bar)
  - [L] Set minsize of desktop application.

- UI Issues
  - [L] Take photo need not confirm again.
  - [M] Zoom in/out for detail photo in mobile. [?]
  - [M] Rotate photo on creating or updating
  - [M] Space does not function well when create/update task

NOT READY
====

- Authenticate
  - Create server-id for each server.
    - Persistent server-id.
    - Share on QRCode.
  - Create client-id on mobile side
    - Persistent client-id.
  - Authentication:
    - Call with server-id and client-id
    - If server-id does not match, reject
    - If succ return client-token respondent to client-id
  - Other calls
    - Use client-token instead of client-id
  - Store information under /<server-id>/
  - Mobile: allow multiple server-id
    - allow switch between different server
    - add nickname for each server
  - Desktop: add server nickname which can is recognized

ISSUE
=====
