NOW
===

Compile as windows services
- Install under windows [DONE]
- Add methodChannel in windows' code [DONE]
- Add open file
- Change script to build backend in windows [DONE]
- Compile backend.lib with app [DONE]
- Start backend from windows code [DONE]
- Use methodChannel to communicate with backend from flutter [DONE]

TODO
====
- Authenticate
- Notify Frontend when change happens in backend
- Force to retry connection

- Change icon for app.
- Set minsize of desktop application.
- Deployment
  - Android
  - MacOS
  - Windows
- Create a website to publish service.
  - Automatic build

- Redesign display photo interface.


- QR Code for real device

ISSUE
=====
- Should have warning bar when can not connect server
- Allow change PORT of backend service
- Take photo need not confirm again.
- Zoom in/out for detail photo in mobile. [?]

DONE
====

UI
- Add Text [DONE]
- List Text [DONE]
- Test case [DONE]
  - Adding succ [DONE]
  - Adding cancelled [DONE]

Widget test [DONE]
- Coverage [DONE]

Server
- Temp Text List [DONE]
- Temp Add Text [DONE]
- Temp Update Text [DONE]
- Temp Delete Text [DONE]

Add sqlite for backend support [DONE]
Run backend and frontend at same time [DONE]

Front-end API
- Query List [DONE]
- Add [DONE]
- Update [DONE]
- Delete [DONE]

UI
- Update Text [DONE]
- Delete Text [DONE]

Create redux-like data storage in front-end [DONE]
Make persist on redux [DONE]
Split func to small widget [DONE]

- Add _ts to trace the updates on backend [DONE]
  - backend [DONE]
  - frontend [DONE]

- Sort Tasks in front-end by updatedAt [DONE]

Test-cases [DONE]
- Frontend [DONE]
- Backend [DONE]

Menu
- Notify Flutter when change happens in macos [DONE]
- Notify MacOS when flutter need to [DONES]

Import Photo
- Backend [DONE]
  - Add Photo [DONE]
  - Delete Photo [DONE]
  - Download Photo [DONE]
  - Thumbnail Photo [DONE]
  - Get Photo Meta Data [DONE]
- Frontend [DONE]
  - API [DONE]
    - Get Photo List [DONE]
    - Add Photo [DONE]
    - Delete Photo [DONE]
    - Download Photo [DONE]
    - Thumbnail Photo [DONE]
  - UI
    - Add Photo [DONE]
    - Delete Photo [DONE]
    - Show Photo [DONE]

- Show Big Photo, zoom and scale [DONE]
  - Zoom view overlap the RESET button [DONE]
- Change Welcome Page [DONE]
- Change Layout of 'add photo' [DONE]
- Wrapper same layout attribute into widget [DONE]
  - Function bar [DONE]
  - Function button in bar [DONE]

Server Send Event [DONE]
- Generate UUID on client side [DONE]
  - Backend [DONE]
    - Func [DONE]
    - Test-case [DONE]
  - Frontend [DONE]
- Only sync updated events [DONE]
- Trigger fetchTasks from last time by sync updated events [DONE]
- Pipeline requests [DONE]
- Keepalive [DONE]


- Running on mobile for import photo [DONE]
  - Android [DONE]
  - iOS [DONE]
- Different behavior by get flutter environment [DONE]
  - Change 'ADD PHOTO' to 'TAKE PHOTO' [DONE]

- Issue:
  - Stop Retry to frequently if server is not available. [DONE]
  - Make font larger for task [DONE]
  - Show flags on task/photo not uploaded [DONE]
    - Add 'local icon' [DONE]
    - Show origin as thumbnail if only have origin [DONE]
  - iOS Layout - bottom line is not fit iPhone. [DONE]

- Change text button to icon button [DONE]
  - Add Task [DONE]
  - Add Photo / Take Photo [DONE]
  - Add / Cancel to add photo [DONE]

- Cancel does not work for mobile devices [DONE]
  - Update task [DONE]
  - Create task [DONE]

- QR code to connect [IN_PROGRESS]
  - Server-side [DONE]
    - Find IP address on backend [DONE]
    - Deliever IP info to flutter [DONE]
    - Show qr code [DONE]
    - Show server key in string [DONE]
    - Switch IP from UI [DONE]
    - Connect to backend by settings [DONE]
      - Happy path [DONE]
      - Check status of backend [DONE]
  - iPhone
    - Scan MOCK [DONE]
  - Android [DONE]
    - Scan basic func [DONE]
    - Customiz QR Code scanner's UI [DONE]
  - Share 
    - Save scaned code to store [DONE]
    - Manually edit server key [DONE]
    - Connect to server [DONE]
      - Happy path [DONE]
      - If failed, ask for update the connection [DONE]
