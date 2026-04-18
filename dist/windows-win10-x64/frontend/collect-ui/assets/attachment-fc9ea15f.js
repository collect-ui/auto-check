import{j as e}from"./excalidraw-dbbfee33.js";import{r as s}from"./echarts-22071690.js";import{c as _,a as N,g as P}from"./index-8c4ea9c9.js";import{G as $}from"./react-icons-f55c2fbe.js";import{g as D,D as Z}from"./docx-preview-717d2ac4.js";import{r as J,u as Q}from"./xlsx-af248e40.js";import{S as W,f as X,E as R,B as z,D as Y,T as ee,F as B,A as te,g as ae,U as ne,h as re,I as se,i as le,j as ie,k as oe,l as ce,n as de,o as he,V as ue,p as xe,q as fe}from"./antd-8f79714f.js";import"./docx-81be5908.js";function ge(t){return $({tag:"svg",attr:{viewBox:"0 0 512 512"},child:[{tag:"path",attr:{d:"M216 0h80c13.3 0 24 10.7 24 24v168h87.7c17.8 0 26.7 21.5 14.1 34.1L269.7 378.3c-7.5 7.5-19.8 7.5-27.3 0L90.1 226.1c-12.6-12.6-3.7-34.1 14.1-34.1H192V24c0-13.3 10.7-24 24-24zm296 376v112c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V376c0-13.3 10.7-24 24-24h146.7l49 49c20.1 20.1 52.5 20.1 72.6 0l49-49H488c13.3 0 24 10.7 24 24zm-124 88c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20zm64 0c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20z"},child:[]}]})(t)}function me(t){return $({tag:"svg",attr:{viewBox:"0 0 448 512"},child:[{tag:"path",attr:{d:"M432 32H312l-9.4-18.7A24 24 0 0 0 281.1 0H166.8a23.72 23.72 0 0 0-21.4 13.3L136 32H16A16 16 0 0 0 0 48v32a16 16 0 0 0 16 16h416a16 16 0 0 0 16-16V48a16 16 0 0 0-16-16zM53.2 467a48 48 0 0 0 47.9 45h245.8a48 48 0 0 0 47.9-45L416 128H32z"},child:[]}]})(t)}function pe(t){return $({tag:"svg",attr:{viewBox:"0 0 512 512"},child:[{tag:"path",attr:{d:"M296 384h-80c-13.3 0-24-10.7-24-24V192h-87.7c-17.8 0-26.7-21.5-14.1-34.1L242.3 5.7c7.5-7.5 19.8-7.5 27.3 0l152.2 152.2c12.6 12.6 3.7 34.1-14.1 34.1H320v168c0 13.3-10.7 24-24 24zm216-8v112c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V376c0-13.3 10.7-24 24-24h136v8c0 30.9 25.1 56 56 56h80c30.9 0 56-25.1 56-56v-8h136c13.3 0 24 10.7 24 24zm-124 88c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20zm64 0c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20z"},child:[]}]})(t)}const ye=({url:t})=>{const[v,w]=s.useState([]),[j,i]=s.useState(""),[x,b]=s.useState({}),[O,F]=s.useState(!0),[o,C]=s.useState(null),f=(r,c)=>r?`
      <div class="excel-container">
        ${r}
      </div>
      <style>
        /* 容器样式 */
        .excel-container {
          overflow-x: auto;
          max-height: 70vh;
          border: 1px solid #e0e0e0;
          background: white;
          font-family: Arial;
        }

        /* 表格样式 */
        .excel-container table {
          border-collapse: collapse;
          min-width: max-content !important;
          width: 100%;
        }

        /* 表头固定 */
        .excel-container th {
          position: sticky;
          top: 0;
          background: #f0f0f0 !important;
          z-index: 2;
          font-weight: bold;
          box-shadow: 0 1px 0 #d9d9d9;
        }

        /* 单元格样式 */
        .excel-container th,
        .excel-container td {
          border: 1px solid #e0e0e0 !important;
          padding: 8px 12px;
          white-space: nowrap;
        }

        /* 斑马纹 */
        .excel-container tr:nth-child(even) {
          background: #f9f9f9 !important;
        }

        /* 悬停效果 */
        .excel-container tr:hover {
          background: #f0f0f0 !important;
        }
         .excel-preview .ant-tabs-nav{
            margin-bottom: 0px;
        
        }
        /* 隐藏首行空单元格（兼容性处理） */
.excel-container tr:first-child td:empty {
  display: none;
}
      </style>
    `:`
        <div class="excel-error">
          <div class="error-message">
            <h4><ExclamationCircleOutlined /> 工作表 "${c}" 无有效数据</h4>
            <p>可能原因：隐藏工作表/图表工作表/空工作表</p>
          </div>
        </div>
        <style>
          .excel-error {
            padding: 24px;
            text-align: center;
            color: #f5222d;
          }
          .excel-error svg {
            margin-right: 8px;
          }
        </style>
      `;return s.useEffect(()=>{(async()=>{try{if(F(!0),C(null),!t||typeof t!="string")throw new Error("无效的文件URL");const c=await fetch(t);if(!c.ok)throw new Error(`请求失败: ${c.status}`);const g=c.headers.get("content-type")||"";if(!(/excel|spreadsheet/.test(g)||t.toLowerCase().endsWith(".xlsx")||t.toLowerCase().endsWith(".xls")))throw new Error("不是有效的Excel文件");const A=await c.arrayBuffer();let l;try{l=J(A,{type:"array"})}catch(d){throw new Error(`解析失败: ${d.message}`)}if(!l.SheetNames?.length)throw new Error("Excel文件中未找到工作表");const u={};l.SheetNames.forEach(d=>{const E=l.Sheets[d];if(!E||!E["!ref"]){u[d]=f(null,d);return}try{let m=Q.sheet_to_html(E,{raw:!0,header:!1,display:!1});m=(p=>{const S=p.indexOf("false"),I=p.indexOf("<table");return S!==-1&&S<I?p.substring(0,S)+p.substring(S+5):p})(m),u[d]=f(m,d)}catch(m){const T=m.message;u[d]=`
              <div class="excel-error">
                <div class="error-message">
                  <h4><ExclamationCircleOutlined /> 工作表 "${d}" 渲染失败</h4>
                  <p>错误详情: ${T}</p>
                  <p>建议: 请在Excel中检查此工作表内容</p>
                </div>
              </div>
            `}}),w(l.SheetNames),i(l.SheetNames[0]),b(u)}catch(c){console.error("Excel加载错误:",c),C(c.message||"未知错误")}finally{F(!1)}})()},[t]),O?e.jsx("div",{style:{textAlign:"center",padding:"40px 0"},children:e.jsx(W,{tip:"正在加载Excel文件...",size:"large"})}):o?e.jsx(X,{type:"error",message:"Excel文件加载失败",description:e.jsxs("div",{style:{marginTop:16},children:[e.jsxs("p",{children:[e.jsx(R,{})," 错误信息: ",o]}),e.jsx(z,{type:"primary",icon:e.jsx(Y,{}),onClick:()=>window.open(t,"_blank"),style:{marginTop:8},children:"下载原始文件检查"})]}),showIcon:!0}):e.jsx("div",{style:{background:"#fff",padding:0,borderRadius:4,boxShadow:"0 1px 3px rgba(0,0,0,0.1)"},children:e.jsx(ee,{activeKey:j,onChange:i,size:"small",type:"card",className:"excel-preview",items:v.map(r=>({key:r,label:e.jsxs("span",{children:[e.jsx(B,{style:{marginRight:8}}),r,x[r]?.includes("excel-error")&&e.jsx(R,{style:{color:"#f5222d",marginLeft:8}})]}),children:e.jsx("div",{dangerouslySetInnerHTML:{__html:x[r]||f(null,r)},style:{marginTop:16}})}))})})},ve=({url:t,style:v})=>{const[w,j]=s.useState(""),[i,x]=s.useState(!0),[b,O]=s.useState(null);return s.useEffect(()=>{(async()=>{try{x(!0);const o=await fetch(t);if(o.ok){const C=await o.text();j(C)}else throw new Error(`Failed to load text file: ${o.status}`)}catch(o){O(o instanceof Error?o.message:"Failed to load text file")}finally{x(!1)}})()},[t]),i?e.jsx("div",{style:{...v,display:"flex",justifyContent:"center",alignItems:"center"},children:e.jsx(W,{tip:"Loading text content..."})}):b?e.jsxs("div",{style:{...v,color:"red",padding:16},children:["Error: ",b]}):e.jsx("div",{style:{...v,overflow:"auto",padding:16,backgroundColor:"#f5f5f5",whiteSpace:"pre-wrap",fontFamily:"monospace",border:"1px solid #d9d9d9",borderRadius:4,lineHeight:1.5},children:w||"Empty text file"})};function Ve(t){const{attachment_prop:v,show_path:w,finish_action:j,uploadConfig:i,placeholder:x,...b}=t,{visible:O,...F}=_.transferProp(b,"attachment"),o=N("dialog");N("icon");const[C,f]=s.useState(!1),[r,c]=s.useState(""),g=te.useApp(),V=_.toApiObj(i?.api);let A={};if(V?.data)for(let a in V.data)A[a]=V.data[a];if(i?.data)for(let a in i?.data){const n=i?.data[a];A[a]=_.varValue(n,t.store,F.target)}const l=i?.multiple||!1,u=t?._target?.row[t?._target?.column?.field],d=()=>{if(!r)return null;switch(P(D(r))){case"word":return e.jsx(Z,{url:r,style:{height:"80vh",overflow:"auto"}});case"pdf":return e.jsx("iframe",{src:r,style:{height:"80vh",width:"100%"}});case"excel":return e.jsx(ye,{url:r});case"properties":case"json":case"xml":case"sql":case"yml":case"text":return e.jsx(ve,{url:r,style:{height:"80vh"}});default:return null}},E=a=>{if(!a)return!1;const n=P(D(a));return["word","pdf","excel","text","properties","json","xml","sql","yml"].includes(n)},m=s.useCallback(a=>{if(a.file.status==="done"){console.log("上传成功后的返回数据:",a.file.response),j&&_.handlerActions(j,t.store,t.rootStore,g,{row:a.file.response});const n=a.file.response.data;t.onChange&&(l?t.onChange([n,...t?.value||[]]):t.onChange(n?.path)),t?._target?.onValueChange&&(t?._target?.onValueChange(n?.path),t?._target?.api.stopEditing())}else a.file.status==="error"&&g?.message?.error(`${a.file.name} 文件上传失败`)},[t.value,l]),T=s.useCallback(a=>{if(t?._target?.onValueChange){if(l){const n=Array.isArray(t.value)?[...t.value].filter((y,h)=>h!==a):[];t._target.onValueChange(n)}else t._target.onValueChange("");t._target.api.stopEditing()}if(t.onChange)if(l){const n=Array.isArray(t.value)?[...t.value].filter((y,h)=>h!==a):[];t.onChange(n)}else t.onChange("")},[t.value,l,t.onChange,t._target]),p=a=>({word:e.jsx(oe,{}),pdf:e.jsx(ce,{}),excel:e.jsx(B,{}),ppt:e.jsx(de,{}),image:e.jsx(he,{}),video:e.jsx(ue,{}),audio:e.jsx(xe,{}),zip:e.jsx(fe,{})})[a]||e.jsx(ie,{}),S=a=>({word:"#2b579a",pdf:"#d24726",excel:"#217346",ppt:"#d24726",zip:"#7e57c2"})[a]||"#999",I=s.useCallback((a,n)=>{if(!a){g?.message?.error("没有可下载的文件");return}try{const y=n||D(a),h=document.createElement("a");h.href=a,h.download=y,document.body.appendChild(h),h.click(),document.body.removeChild(h),g?.message?.success(`开始下载: ${y}`)}catch{g?.message?.error("下载文件时出错")}},[]),M=({file:a,index:n,onPreview:y,onDownload:h,onRemove:G,showPreview:K=!0})=>{const k=a.path||a;debugger;const H=D(k),L=P(H);return e.jsxs("div",{style:{width:120,height:120,border:"1px solid #d9d9d9",borderRadius:4,padding:8,display:"flex",flexDirection:"column",position:"relative",backgroundColor:"#fafafa",overflow:"hidden"},children:[e.jsx("div",{style:{height:80,display:"flex",justifyContent:"center",alignItems:"center",overflow:"hidden"},children:L==="image"?e.jsx("div",{style:{display:"inline-flex",maxWidth:"100%",maxHeight:"100%"},children:e.jsx(se,{src:k,style:{maxWidth:"100%",maxHeight:"100%",objectFit:"contain",display:"block",borderRadius:4,cursor:"pointer"},preview:{mask:null,src:k}})}):e.jsx("div",{style:{fontSize:48,color:S(L),textAlign:"center"},children:p(L)})}),e.jsx("div",{style:{marginTop:8,whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis",fontSize:12,textAlign:"center"},title:H,children:H}),e.jsxs("div",{style:{position:"absolute",bottom:0,right:4,display:"flex",gap:4},children:[K&&E(k)&&e.jsx(z,{size:"small",type:"text",icon:e.jsx(le,{}),onClick:()=>y(k),style:{color:"#1890ff"}}),e.jsx(z,{size:"small",type:"text",icon:e.jsx(ge,{}),onClick:()=>h(k,H),style:{color:"#52c41a"}}),e.jsx(z,{size:"small",type:"text",icon:e.jsx(me,{}),onClick:()=>G(n),style:{color:"#ff4d4f"}})]})]})},U=s.useCallback(a=>{c(a),f(!0)},[]),q=s.useCallback(()=>l&&Array.isArray(t.value)?t.value:t.value||u?[t.value||u]:[],[l,t.value,u]);return _.getVisible(t)?e.jsxs(e.Fragment,{children:[e.jsxs(ae.Compact,{style:{width:"100%"},children:[e.jsx(ne,{...i,onChange:m,name:"file",action:V?.url,data:a=>({...A}),children:e.jsx(z,{icon:e.jsx(pe,{}),type:"primary",children:!w&&"上传文件"})}),w&&e.jsx(e.Fragment,{children:e.jsx(re,{value:t.value||u,onChange:t.onChange||t?._target?.onValueChange,placeholder:x})})]}),e.jsx("div",{style:{marginTop:16,display:"flex",flexWrap:"wrap",gap:12,maxWidth:"100%"},children:q().map((a,n)=>e.jsx(M,{file:a,index:n,onPreview:U,onDownload:I,onRemove:T},n))}),E(r)&&e.jsx(o,{width:"80%",style:{top:"20px"},onOk:()=>f(!1),onCancel:()=>f(!1),open:C,title:"预览文档",children:d()})]}):null}export{Ve as default};
