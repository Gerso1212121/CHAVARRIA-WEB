const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Cliente de Supabase usando la Service Role Key
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// 🔒 Cambiar contraseña si el usuario existe
app.post('/reset-password', async (req, res) => {
  const { email, nuevaContrasena } = req.body;

  if (!email || !nuevaContrasena) {
    return res.status(400).json({ error: 'Correo y contraseña requerida' });
  }

  try {
    const { data: userList, error: listError } = await supabase.auth.admin.listUsers();
    if (listError) throw listError;

    const user = userList.users.find(u => u.email === email);
    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado con ese correo' });
    }

    const { data, error: updateError } = await supabase.auth.admin.updateUserById(user.id, {
      password: nuevaContrasena,
    });

    if (updateError) throw updateError;

    res.json({ message: 'Contraseña actualizada correctamente', data });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Error desconocido' });
  }
});

// ✅ Verificar si el usuario existe por correo
app.post('/usuario-existe', async (req, res) => {
  const { correo } = req.body;

  if (!correo) {
    return res.status(400).json({ error: 'Correo requerido' });
  }

  try {
    const { data: users, error } = await supabase.auth.admin.listUsers();
    if (error) throw error;

    const existe = users.users.some(u => u.email === correo);
    return res.json({ existe });
  } catch (err) {
    return res.status(500).json({ error: err.message || 'Error en la verificación' });
  }
});

// 🚀 Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor corriendo en http://localhost:${PORT}`);
});
