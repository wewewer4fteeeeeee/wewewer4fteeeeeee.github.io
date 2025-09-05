from flask import Flask, request, Response
import requests

app = Flask(__name__)

# -------- Proxy Backend --------
@app.route("/proxy")
def proxy():
    url = request.args.get("url")
    if not url:
        return "No URL provided", 400

    try:
        r = requests.get(url, headers={k:v for k,v in request.headers if k.lower() != "host"}, stream=True, timeout=15)
    except Exception as e:
        return f"Error fetching {url}: {e}", 500

    # Strip frame-blocking headers
    excluded = ["content-encoding", "content-length", "transfer-encoding", "connection", 
                "x-frame-options", "content-security-policy"]
    headers = [(k, v) for k, v in r.headers.items() if k.lower() not in excluded]

    return Response(r.content, status=r.status_code, headers=headers)


# -------- Frontend --------
@app.route("/")
def index():
    return """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Flask Browser Proxy</title>
<style>
body { margin:0; font-family:sans-serif; background:#1e1e1e; color:#fff; }
#toolbar { background:#333; padding:6px; display:flex; align-items:center; gap:5px; }
#address { flex:1; padding:6px; border:none; border-radius:4px; }
button { padding:6px 10px; border:none; border-radius:4px; background:#555; color:#fff; cursor:pointer; }
button:hover { background:#777; }
#tabs { display:flex; background:#222; border-bottom:1px solid #444; }
.tab { padding:6px 8px; cursor:pointer; background:#222; color:#aaa; display:flex; align-items:center; }
.tab.active { background:#444; color:#fff; }
.tab .close { margin-left:6px; color:red; cursor:pointer; }
#browser { position:relative; height:calc(100vh - 120px); }
iframe { position:absolute; top:0; left:0; width:100%; height:100%; border:none; display:none; }
iframe.active { display:block; }
#devtools { background:#111; border-top:1px solid #444; height:200px; display:none; }
#devtabs { display:flex; background:#222; }
.devtab { padding:6px 8px; cursor:pointer; background:#222; color:#aaa; }
.devtab.active { background:#444; color:#fff; }
#devcontent { height:calc(100% - 30px); overflow:auto; padding:8px; font-size:12px; white-space:pre-wrap; }
</style>
</head>
<body>

<div id="tabs"></div>
<div id="toolbar">
  <button onclick="newTab()">+</button>
  <button onclick="goBack()">Back</button>
  <button onclick="goForward()">Forward</button>
  <button onclick="reload()">Reload</button>
  <input type="text" id="address" placeholder="Enter URL"/>
  <button onclick="go()">Go</button>
  <button onclick="toggleDev()">DevTools</button>
</div>
<div id="browser"></div>

<div id="devtools">
  <div id="devtabs">
    <div class="devtab active" onclick="switchDev('headers')">Headers</div>
    <div class="devtab" onclick="switchDev('preview')">Preview</div>
    <div class="devtab" onclick="switchDev('console')">Console</div>
  </div>
  <div id="devcontent"><pre id="devheaders"></pre><pre id="devpreview" style="display:none;"></pre><pre id="devconsole" style="display:none;"></pre></div>
</div>

<script>
let tabs = [];
let activeTab = null;

function newTab(url="https://example.com") {
  const id = Date.now();
  const tab = document.createElement("div");
  tab.className = "tab";
  tab.textContent = "New Tab";
  const closeBtn = document.createElement("span");
  closeBtn.textContent = "✖";
  closeBtn.className = "close";
  closeBtn.onclick = (e) => { e.stopPropagation(); closeTab(id); };
  tab.appendChild(closeBtn);
  tab.onclick = () => switchTab(id);
  document.getElementById("tabs").appendChild(tab);

  const iframe = document.createElement("iframe");
  iframe.id = "tab-"+id;
  document.getElementById("browser").appendChild(iframe);

  tabs.push({ id, tab, iframe, history:[], current:0 });
  switchTab(id);
  loadURL(url);
}

function switchTab(id) {
  tabs.forEach(t => {
    t.tab.classList.remove("active");
    t.iframe.classList.remove("active");
  });
  const current = tabs.find(t => t.id === id);
  if (current) {
    current.tab.classList.add("active");
    current.iframe.classList.add("active");
    activeTab = current;
    if (activeTab.history.length > 0) {
      document.getElementById("address").value = activeTab.history[activeTab.current];
    }
  }
}

function loadURL(url) {
  if (!activeTab) return;
  if (!url.startsWith("http")) url = "http://" + url;
  const proxied = "/proxy?url=" + encodeURIComponent(url);
  activeTab.iframe.src = proxied;

  activeTab.history = activeTab.history.slice(0, activeTab.current+1);
  activeTab.history.push(url);
  activeTab.current = activeTab.history.length-1;

  activeTab.tab.childNodes[0].nodeValue = new URL(url).hostname;
  document.getElementById("address").value = url;

  fetch(proxied).then(async res => {
    let headers = "";
    for (let [k,v] of res.headers.entries()) headers += k+": "+v+"\\n";
    let body = await res.text();
    document.getElementById("devheaders").textContent = headers;
    document.getElementById("devpreview").textContent = body.substring(0,3000);
  });
}

function go() { loadURL(document.getElementById("address").value); }
function reload() { if (activeTab) loadURL(activeTab.history[activeTab.current]); }
function goBack() {
  if (activeTab && activeTab.current > 0) {
    activeTab.current--;
    loadURL(activeTab.history[activeTab.current]);
  }
}
function goForward() {
  if (activeTab && activeTab.current < activeTab.history.length-1) {
    activeTab.current++;
    loadURL(activeTab.history[activeTab.current]);
  }
}
function closeTab(id) {
  const idx = tabs.findIndex(t => t.id === id);
  if (idx !== -1) {
    tabs[idx].tab.remove();
    tabs[idx].iframe.remove();
    tabs.splice(idx,1);
    if (tabs.length>0) switchTab(tabs[0].id);
    else activeTab=null;
  }
}
function toggleDev() {
  const panel = document.getElementById("devtools");
  panel.style.display = (panel.style.display==="block")?"none":"block";
}
function switchDev(type) {
  document.querySelectorAll(".devtab").forEach(t=>t.classList.remove("active"));
  document.querySelectorAll("#devcontent pre").forEach(p=>p.style.display="none");
  document.querySelector(".devtab[onclick*='"+type+"']").classList.add("active");
  document.getElementById("dev"+type).style.display = "block";
}

// Capture console logs into DevTools
(function(){
  const oldLog = console.log;
  console.log = function(...args){
    oldLog.apply(console, args);
    let log = args.map(a=> (typeof a==="object"?JSON.stringify(a):a)).join(" ");
    let el = document.getElementById("devconsole");
    el.textContent += log+"\\n";
  }
})();

document.getElementById("address").addEventListener("keydown", e=>{
  if (e.key==="Enter") go();
});

newTab("https://example.com");
</script>
</body>
</html>
"""

if __name__ == "__main__":
    app.run("0.0.0.0", 5000, debug=False)
