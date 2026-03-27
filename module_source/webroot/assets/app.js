const packageOptions = [
  { value: 'com.activision.callofduty.shooter', label: 'Global' },
  { value: 'com.garena.game.codm', label: 'Garena' },
  { value: 'com.tencent.tmgp.kr.codm', label: 'KR/VNG' }
];
const resolutionOptions = ['0.3x','0.4x','0.5x','0.6x','0.7x','0.75x','0.8x','0.85x','0.9x','Off'];
const fpsOptions = ['30','45','60','90','120','144'];
const configPath = '/data/adb/codmwebui/config.json';
const logPath = '/data/adb/codmwebui/service.log';
const applyScript = '/data/adb/modules/codmwebui_real/apply.sh';
const resetScript = '/data/adb/modules/codmwebui_real/reset.sh';

const state = {
  package: 'com.activision.callofduty.shooter',
  resolution: '0.75x',
  fps: '120',
  disableDoze: false,
  lockFps: false,
  autoReapply: true,
};

function renderGroup(targetId, options, key, mapper = (v) => ({value:v,label:v})) {
  const host = document.getElementById(targetId);
  host.innerHTML = '';
  options.forEach((rawValue) => {
    const item = mapper(rawValue);
    const btn = document.createElement('button');
    btn.className = 'chip' + (state[key] === item.value ? ' active' : '');
    btn.textContent = item.label;
    btn.addEventListener('click', () => {
      state[key] = item.value;
      renderAll();
      refreshCommandPreview();
    });
    host.appendChild(btn);
  });
}

function showToast(message) {
  const toast = document.getElementById('toast');
  toast.textContent = message;
  toast.classList.add('show');
  clearTimeout(showToast._timer);
  showToast._timer = setTimeout(() => toast.classList.remove('show'), 1800);
}

function setStatus(message) {
  document.getElementById('statusBox').textContent = 'Status: ' + message;
}

function setConsole(message, append = false) {
  const box = document.getElementById('consoleBox');
  box.textContent = append ? box.textContent + '\n' + message : message;
  box.scrollTop = box.scrollHeight;
}

function buildPayload() {
  return {
    ...state,
    updatedAt: new Date().toISOString()
  };
}

function writeConfig(payload) {
  const json = JSON.stringify(payload, null, 2);
  if (window.ksu && typeof window.ksu.exec === 'function') {
    const cmd = `mkdir -p /data/adb/codmwebui && cat > ${configPath} <<'EOF'\n${json}\nEOF`;
    return Promise.resolve(window.ksu.exec(cmd));
  }
  localStorage.setItem('codmTweaksConfig', json);
  return Promise.resolve({ stdout: 'saved to localStorage fallback', code: 0 });
}

function runExec(cmd) {
  if (window.ksu && typeof window.ksu.exec === 'function') {
    return Promise.resolve(window.ksu.exec(cmd));
  }
  return Promise.resolve({ stdout: 'ksu.exec unavailable in preview mode', code: 0 });
}

async function runScript(path) {
  return runExec(`sh ${path}`);
}

function normalizeScale(value) {
  return value === 'Off' ? 'disable' : value.replace('x', '');
}

function generatedCommands() {
  const scale = normalizeScale(state.resolution);
  const pkg = state.package;
  const lines = [];
  if (state.disableDoze) {
    lines.push('dumpsys deviceidle disable');
    lines.push('settings put global device_idle_constants inactive_to=86400000');
  }
  if (state.lockFps) {
    lines.push(`settings put system peak_refresh_rate ${state.fps}`);
    lines.push(`settings put system min_refresh_rate ${state.fps}`);
  }
  if (scale === 'disable') {
    lines.push(`cmd game downscale disable ${pkg}`);
    lines.push(`cmd device_config delete game_overlay ${pkg}`);
  } else {
    lines.push(`cmd game mode performance ${pkg}`);
    lines.push(`cmd game downscale ${scale} ${pkg}`);
    lines.push(`cmd device_config put game_overlay ${pkg} mode=2,downscaleFactor=${scale},fps=${state.fps}`);
  }
  return lines.join('\n');
}

function refreshCommandPreview() {
  document.getElementById('shizukuCmds').value = generatedCommands();
}

async function refreshLog() {
  const result = await runExec(`tail -n 80 ${logPath} 2>/dev/null || echo 'No log yet'`);
  const text = result && (result.stdout || result.stderr || JSON.stringify(result));
  setConsole(text || 'No output');
}

async function saveSettings() {
  const payload = buildPayload();
  localStorage.setItem('codmTweaksConfig', JSON.stringify(payload));
  await writeConfig(payload);
  setStatus('saved config');
  setConsole('Config saved.\n\n' + generatedCommands());
  showToast('Config saved');
}

async function applySettings() {
  const payload = buildPayload();
  localStorage.setItem('codmTweaksConfig', JSON.stringify(payload));
  await writeConfig(payload);
  const result = await runScript(applyScript);
  setStatus(`applied ${state.resolution} @ ${state.fps}fps to ${state.package}`);
  setConsole((result && (result.stdout || result.stderr)) || 'Apply executed. Check log below.');
  await refreshLog();
  showToast('Applied to CODM');
}

async function resetSettings() {
  state.resolution = 'Off';
  state.fps = '120';
  state.disableDoze = false;
  state.lockFps = false;
  renderAll();
  refreshCommandPreview();
  const payload = buildPayload();
  localStorage.setItem('codmTweaksConfig', JSON.stringify(payload));
  await writeConfig(payload);
  const result = await runScript(resetScript);
  setStatus('reset done');
  setConsole((result && (result.stdout || result.stderr)) || 'Reset executed.');
  await refreshLog();
  showToast('Reset applied');
}

function loadSaved() {
  try {
    const saved = JSON.parse(localStorage.getItem('codmTweaksConfig') || '{}');
    Object.assign(state, saved);
  } catch (_) {}
}

function renderAll() {
  renderGroup('packageGrid', packageOptions, 'package', (v) => v);
  renderGroup('resolutionGrid', resolutionOptions, 'resolution');
  renderGroup('fpsGrid', fpsOptions, 'fps');
  document.getElementById('disableDoze').checked = !!state.disableDoze;
  document.getElementById('lockFps').checked = !!state.lockFps;
  document.getElementById('autoReapply').checked = !!state.autoReapply;
}

loadSaved();
renderAll();
refreshCommandPreview();
refreshLog();
setInterval(refreshLog, 5000);

document.getElementById('disableDoze').addEventListener('change', (e) => {
  state.disableDoze = e.target.checked;
  refreshCommandPreview();
});

document.getElementById('lockFps').addEventListener('change', (e) => {
  state.lockFps = e.target.checked;
  refreshCommandPreview();
});

document.getElementById('autoReapply').addEventListener('change', (e) => {
  state.autoReapply = e.target.checked;
});

document.getElementById('saveBtn').addEventListener('click', saveSettings);
document.getElementById('applyBtn').addEventListener('click', applySettings);
document.getElementById('resetBtn').addEventListener('click', resetSettings);
document.getElementById('copyCmdBtn').addEventListener('click', async () => {
  const text = document.getElementById('shizukuCmds').value;
  try {
    await navigator.clipboard.writeText(text);
    showToast('Commands copied');
  } catch (_) {
    showToast('Copy failed');
  }
});
