# ⚙️ Configuración Supabase — Pasos Pendientes (Una sola vez)

## 1. Ejecutar el SQL de `perfiles_ciudadanos`

Ir a **Supabase Dashboard → SQL Editor** y pegar el contenido de `supabase_schema.sql`
a partir de la sección `-- TABLA: perfiles_ciudadanos`.

---

## 2. Configurar la URL de redirección (Deep Link para recuperación)

1. Ir a **Supabase Dashboard → Authentication → URL Configuration**
2. En **"Redirect URLs"** añadir: `bugareport://nueva-contrasena`
3. Guardar.

---

## 3. Personalizar plantilla del correo de recuperación (opcional pero recomendado)

1. Ir a **Authentication → Email Templates → "Reset Password"**
2. Cambiar el asunto a: `BugaReport — Restablece tu contraseña`
3. En el cuerpo, puedes personalizar el HTML con los colores de BugaReport.

---

## 4. Configurar tiempo de expiración del token de recuperación

1. Ir a **Authentication → Settings**
2. En **"JWT Expiry"** y **"OTP Expiry"**: Establecer a `900` (15 minutos) o `3600` (1 hora)

---

## 5. Variables de entorno `.env` (ya configurado)

```
SUPABASE_URL=https://btojaigpghwwgegtxqnu.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

> El `.env` está en `.gitignore` — nunca sube a GitHub ✓
