const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Supabase client usando service role key
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

app.post('/reset-password', async (req, res) => {
  const { email, nuevaContrasena } = req.body;

  if (!email || !nuevaContrasena) {
    return res.status(400).json({ error: 'Correo y contraseña requerida' });
  }

  try {
    // 1. Obtener todos los usuarios
    const { data: userList, error: listError } = await supabase.auth.admin.listUsers();
    if (listError) throw listError;

    // 2. Buscar el usuario por email
    const user = userList.users.find(u => u.email === email);
    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado con ese correo' });
    }

    // 3. Actualizar la contraseña usando el user.id
    const { data, error: updateError } = await supabase.auth.admin.updateUserById(user.id, {
      password: nuevaContrasena,
    });

    if (updateError) throw updateError;

    res.json({ message: 'Contraseña actualizada correctamente', data });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Error desconocido' });
  }
});

// 🎯 Escucha en puerto Render o local
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor corriendo en http://localhost:${PORT}`);
});
