window.addEventListener("DOMContentLoaded", async () => {
  const status = document.getElementById("status");
  const fallback = document.getElementById("fallback");

  const setStatus = (text) => {
    status.textContent = text;
  };

  try {
    setStatus("正在等待本地服务就绪…");
    const target = await window.go.main.App.WaitAndGetTargetURL();
    fallback.href = target;
    fallback.hidden = false;
    setStatus("本地服务已启动，正在进入默认页面…");
    setTimeout(() => {
      window.location.replace(target);
    }, 300);
  } catch (error) {
    console.error(error);
    setStatus("启动失败，请确认同目录存在 main.exe、conf、collect、frontend、database。");
  }
});
