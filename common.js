const cfg=window.ADORN_CONFIG;const sb=window.supabase.createClient(cfg.SUPABASE_URL,cfg.SUPABASE_KEY);
const esc=v=>String(v??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]));
function getCart(){try{const c=JSON.parse(localStorage.adornCart||"[]");return Array.isArray(c)?c:[]}catch{return[]}}
function saveCart(c){localStorage.adornCart=JSON.stringify(c);updateCartCount()}
function updateCartCount(){const n=getCart().reduce((a,x)=>a+Number(x.qty||0),0);document.querySelectorAll(".cart-count").forEach(e=>e.textContent=n)}
function addToCart(p){let c=getCart(),x=c.find(x=>String(x.id)===String(p.id));if(x){x.qty=Number(x.qty||0)+1;x.image_url=p.image_url||x.image_url}else c.push({id:p.id,name:p.name,price:Number(p.price||0),image_url:p.image_url||null,qty:1});saveCart(c)}
async function hydrateCartImages(){const c=getCart();const ids=c.map(x=>x.id).filter(Boolean);if(!ids.length)return c;try{const r=await sb.from("products").select("id,name,price,image_url").in("id",ids);if(!r.error){const byId=new Map((r.data||[]).map(p=>[String(p.id),p]));c.forEach(x=>{const p=byId.get(String(x.id));if(p){x.name=p.name;x.price=Number(p.price||0);x.image_url=p.image_url||x.image_url||null}});saveCart(c)}}catch(e){console.warn("Could not refresh cart images",e)}return c}
const menuBtn=document.querySelector(".menu-btn"),nav=document.querySelector(".nav");if(menuBtn)menuBtn.onclick=()=>nav.classList.toggle("show");updateCartCount();
