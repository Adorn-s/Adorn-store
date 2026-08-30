-- Run this whole file once in Supabase SQL Editor. It prepares products, image storage and customer orders.

alter table public.products add column if not exists id uuid default gen_random_uuid();
alter table public.products add column if not exists name text;
alter table public.products add column if not exists price numeric default 0;
alter table public.products add column if not exists description text;
alter table public.products add column if not exists image_url text;
alter table public.products add column if not exists category text;
alter table public.products add column if not exists created_at timestamptz default now();
alter table public.products enable row level security;
drop policy if exists "Public can read products" on public.products;
create policy "Public can read products" on public.products for select to anon,authenticated using (true);
drop policy if exists "Admin can insert products" on public.products;
create policy "Admin can insert products" on public.products for insert to authenticated with check ((auth.jwt()->>'email')='sj3783967@gmail.com');
drop policy if exists "Admin can update products" on public.products;
create policy "Admin can update products" on public.products for update to authenticated using ((auth.jwt()->>'email')='sj3783967@gmail.com') with check ((auth.jwt()->>'email')='sj3783967@gmail.com');
drop policy if exists "Admin can delete products" on public.products;
create policy "Admin can delete products" on public.products for delete to authenticated using ((auth.jwt()->>'email')='sj3783967@gmail.com');

insert into storage.buckets (id,name,public) values ('products','products',true) on conflict (id) do update set public=true;
drop policy if exists "Public can view product images" on storage.objects;
create policy "Public can view product images" on storage.objects for select to public using (bucket_id='products');
drop policy if exists "Admin can upload product images" on storage.objects;
create policy "Admin can upload product images" on storage.objects for insert to authenticated with check (bucket_id='products' and (auth.jwt()->>'email')='sj3783967@gmail.com');
drop policy if exists "Admin can update product images" on storage.objects;
create policy "Admin can update product images" on storage.objects for update to authenticated using (bucket_id='products' and (auth.jwt()->>'email')='sj3783967@gmail.com') with check (bucket_id='products' and (auth.jwt()->>'email')='sj3783967@gmail.com');
drop policy if exists "Admin can delete product images" on storage.objects;
create policy "Admin can delete product images" on storage.objects for delete to authenticated using (bucket_id='products' and (auth.jwt()->>'email')='sj3783967@gmail.com');

create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 customer_name text not null,
 customer_phone text not null,
 customer_address text not null,
 items jsonb not null,
 total numeric not null default 0,
 created_at timestamptz not null default now()
);
alter table public.orders enable row level security;
drop policy if exists "Anyone can create orders" on public.orders;
create policy "Anyone can create orders" on public.orders for insert to anon,authenticated with check (true);
drop policy if exists "Owner can view orders" on public.orders;
create policy "Owner can view orders" on public.orders for select to authenticated using ((auth.jwt()->>'email')='sj3783967@gmail.com');
drop policy if exists "Owner can delete orders" on public.orders;
create policy "Owner can delete orders" on public.orders for delete to authenticated using ((auth.jwt()->>'email')='sj3783967@gmail.com');
