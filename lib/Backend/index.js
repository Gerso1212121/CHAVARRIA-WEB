const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Corregido: así se usan variables de entorno
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
        const { data, error } = await supabase.auth.admin.updateUserByEmail(email, {
            password: nuevaContrasena,
        });

        if (error) throw error;

        res.json({ message: 'Contraseña actualizada correctamente', data });
    } catch (err) {
        res.status(500).json({ error: err.message || 'Error desconocido' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
