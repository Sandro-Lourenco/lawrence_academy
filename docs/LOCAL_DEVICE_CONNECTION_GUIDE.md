# Local Device Connection Guide

## 1. Network Topology
To run and test the Flutter application on a physical mobile device while hosting the FastAPI backend on your local computer, configure your environments using this setup:

```
[Mobile Device] 
      │ (WiFi Network)
      ▼
[Host PC Wifi IP] ──► (PortProxy / Bridge) ──► [FastAPI Host Port]
e.g. 192.168.0.15:8000                           localhost:8000
```

## 2. Command Line Execution

### Run backend:
Execute this command in the `backend` folder:
```bash
python -m uvicorn src.main:app --host 0.0.0.0 --port 8000
```

### Check Backend Accessibility:
Open the browser on your mobile device and navigate to:
```
http://192.168.0.15:8000/health
```
Ensure you receive `{"status": "healthy"}` before running the Flutter app.

### Run Flutter:
Launch the Flutter app on the mobile device with `--dart-define` keys to override default IPs:
```bash
flutter run \
  --dart-define=ENV=dev \
  --dart-define=API_BASE_URL=http://192.168.0.15:8000
```

## 3. Troubleshooting
- **Firewall block:** Add an inbound rule in Windows Defender Firewall to allow traffic on port `8000`.
- **Subnet mismatch:** Ensure both devices are connected to the exact same wireless access point.
