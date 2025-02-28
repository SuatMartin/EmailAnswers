require("dotenv").config();
const express = require("express");
const mysql = require("mysql2");
const nodemailer = require("nodemailer");
const cron = require("node-cron");
const cors = require('cors');
const bcrypt = require("bcryptjs");

const app = express();
app.use(cors());
app.use(express.json());

const UPDATE_DATABASE = process.env.ENDPOINT_UPDATE_DATABASE;
const REGISTER = process.env.ENDPOINT_REGISTER;
const LOGIN = process.env.ENDPOINT_LOGIN;
const UPDATE_PASSWORD = process.env.ENDPOINT_UPDATE_PASSWORD;
const UPDATE_ROLE = process.env.ENDPOINT_UPDATE_ROLE;
const GET_USERS = process.env.ENDPOINT_GET_USERS;
const DELETE_USER = process.env.ENDPOINT_DELETE_USER;
const SEND_REPORT = process.env.ENDPOINT_SEND_REPORT;
const ADMIN_CHANGE = process.env.ENDPOINT_ADMIN_CHANGE;
const CHECK_ADMIN_CHANGE = process.env.ENDPOINT_CHECK_ADMIN_CHANGE;
const DELETE_ADMIN_CHANGE = process.env.ENDPOINT_DELETE_ADMIN_CHANGE;

// Database Connection
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

db.connect((err) => {
  if (err) {
    console.error("Database connection failed:", err);
    process.exit(1);
  }
  console.log("✅ Connected to MySQL Database");
});

app.post(UPDATE_DATABASE, (req, res) => {
  const { from_name, question } = req.body;

  if (!from_name || !question) {
      return res.status(400).json({ error: "Missing from_name or question" });
  }

  // Check if the user exists (case-insensitive)
  db.query(process.env.UPDATE_QUERY, [from_name], (err, results) => {
      if (err) {
          console.error("❌ Database error:", err);
          return res.status(500).json({ error: "Database error" });
      }

      if (results.length === 0) {
          // User does not exist, create them with questions_answered = 1
          db.query(process.env.INSERT_USER_QUERY, [from_name, 1], (err, insertResult) => {
              if (err) {
                  console.error("❌ Error inserting new user:", err);
                  return res.status(500).json({ error: "Failed to create new user" });
              }

              const newUserId = insertResult.insertId;
              console.log(`✅ New user created: ${from_name} (ID: ${newUserId})`);

              // Insert the answer
              db.query(process.env.INSERT_ANSWER_QUERY, [newUserId, question], (err) => {
                  if (err) {
                      console.error("❌ Error inserting answer:", err);
                      return res.status(500).json({ error: "Failed to insert answer" });
                  }

                  console.log("✅ Database updated: New user added and answer recorded.");
                  res.status(200).json({ message: "New user created and database updated successfully" });
              });
          });
      } else {
          // User exists, update question count and insert answer
          const userId = results[0].user_id;
          const updatedCount = results[0].questions_answered + 1;

          db.query(process.env.UPDATE_USER_QUERY, [updatedCount, userId], (err) => {
              if (err) {
                  console.error("❌ Error updating user count:", err);
                  return res.status(500).json({ error: "Failed to update user count" });
              }

              db.query(process.env.INSERT_ANSWER_QUERY, [userId, question], (err) => {
                  if (err) {
                      console.error("❌ Error inserting answer:", err);
                      return res.status(500).json({ error: "Failed to insert answer" });
                  }

                  console.log("✅ Database updated: User count incremented and answer recorded.");
                  res.status(200).json({ message: "Database updated successfully" });
              });
          });
      }
  });
});

app.post(REGISTER, (req, res) => {
  const { username, password, email, role } = req.body;

  if (!username || !password || !email || !role) {
    return res.status(400).json({ error: "Missing username, password, email, or role" });
  }

  // Hash the password
  bcrypt.hash(password, 10, (err, hashedPassword) => {
    if (err) {
      console.error("❌ Error hashing password:", err);
      return res.status(500).json({ error: "Error hashing password" });
    }

    // Insert into user_credentials table
    db.query(process.env.REGISTER_USER_QUERY, [username, hashedPassword, email], (err, result) => {
      if (err) {
        console.error("❌ Error inserting into users_credentials:", err);
        return res.status(500).json({ error: "Failed to register user" });
      }

      // Get the user_id of the newly created user
      const newUserId = result.insertId;

      // Insert into user_roles table
      db.query(process.env.REGISTER_ROLE_QUERY, [newUserId, role], (err) => {
        if (err) {
          console.error("❌ Error inserting into user_roles:", err);
          return res.status(500).json({ error: "Failed to assign role to user" });
        }

        console.log(`✅ New user registered: ${email} (ID: ${newUserId})`);
        res.status(201).json({ message: "User registered successfully" });
      });
    });
  });
});

app.post(ADMIN_CHANGE, (req, res) => {
  const { username, email } = req.body;

  if (!username || !email) {
    return res.status(400).json({ error: "Missing username or email" });
  }

  // Insert into admin_changed table
  db.query(process.env.ADMIN_CHANGE_QUERY, [username, email], (err, result) => {
    if (err) {
      console.error("❌ Error inserting into admin_changed:", err);
      return res.status(500).json({ error: "Failed to log admin change" });
    }

    console.log(`✅ Admin change logged: ${username}, ${email}`);
    res.status(201).json({ message: "Admin change recorded successfully" });
  });
});

app.post(CHECK_ADMIN_CHANGE, (req, res) => {
  const {email} = req.body;

  if (!email) {
    return res.status(400).json({ error: "Missing email" });
  }

  const query = process.env.CHECK_ADMIN_CHANGE_QUERY;
  db.query(query, [email], (err, results) => {
    if (err) {
      console.error("❌ Error checking admin_changed table:", err);
      return res.status(500).json({ error: "Database error" });
    }

    if (results.length > 0) {
      console.log(`✅ User found in admin_changed: ${email}`);
      return res.status(200).json({ requiresPasswordChange: true });
    }

    return res.status(200).json({ requiresPasswordChange: false });
  });
});

app.delete(DELETE_ADMIN_CHANGE, (req, res) => {
  const { username, email } = req.body;

  if (!username || !email) {
    return res.status(400).json({ error: 'Username and email are required' });
  }

  // Assuming DELETE_ADMIN_CHANGE_QUERY is defined in your .env file
  db.query(process.env.DELETE_ADMIN_CHANGE_QUERY, [username, email], (err, adminResult) => {
    if (err) {
      console.error("❌ Error deleting from admin_changed:", err);
      return res.status(500).json({ error: "Failed to delete admin changed entry" });
    }

    // Check if any rows were deleted
    if (adminResult.affectedRows > 0) {  // For MySQL, use affectedRows
      return res.status(200).json({ message: 'User successfully removed from the admin_changed table' });
    } else {
      return res.status(404).json({ error: 'User not found in the admin_changed table' });
    }
  });
});

app.post(LOGIN, (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: "Missing username or password" });
  }

  db.query(process.env.GET_USER_BY_EMAIL_QUERY, [username], (err, results) => {
    if (err) {
      console.error("❌ Database error:", err);
      return res.status(500).json({ error: "Database error" });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: "Username not found" });
    }

    const user = results[0];

    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err) {
        console.error("❌ Error comparing passwords:", err);
        return res.status(500).json({ error: "Error comparing passwords" });
      }

      if (!isMatch) {
        return res.status(401).json({ error: "Incorrect password" });
      }

      // Fetch the user role
      db.query(process.env.GET_USER_ROLE_QUERY, [user.user_id], (err, roleResults) => {
        if (err) {
          console.error("❌ Error fetching user role:", err);
          return res.status(500).json({ error: "Error fetching role" });
        }

        const role = roleResults[0]?.role;

        // Return username, role, and redirect path in the response
        res.status(200).json({
          message: "Login successful",
          redirect: role === "admin" ? "/admin" : "/user",
          username: user.username, // Ensure this is the username
          user_id: user.user_id,
          role: role  // Add the role here
        });
      });
    });
  });
});

app.put(UPDATE_PASSWORD, (req, res) => {
  const { username, email, newPassword } = req.body;

  if (!username || !email || !newPassword) {
    return res.status(400).json({ error: "Missing username, email, or new password" });
  }

  // Check if user exists
  db.query(process.env.UPDATE_USER_QUERY, [username, email], (err, results) => {
    if (err) {
      console.error("❌ Error finding user:", err);
      return res.status(500).json({ error: "Database error" });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: "User not found. Please check username and email." });
    }

    const userId = results[0].user_id; // Use correct column name

    // Hash the new password
    bcrypt.hash(newPassword, 10, (err, hashedPassword) => {
      if (err) {
        console.error("❌ Error hashing password:", err);
        return res.status(500).json({ error: "Error hashing password" });
      }

      // Update password in database
      db.query(process.env.UPDATE_PASSWORD_QUERY, [hashedPassword, userId], (err) => {
        if (err) {
          console.error("❌ Error updating password:", err);
          return res.status(500).json({ error: "Failed to update password" });
        }

        console.log(`✅ Password updated for user: ${email}`);
        res.status(200).json({ message: "Password updated successfully" });
      });
    });
  });
});

app.put(UPDATE_ROLE, (req, res) => {
  const { user_id, role } = req.body;

  if (!user_id || !role) {
    return res.status(400).json({ error: "Missing user_id or role" });
  }

  db.query(process.env.UPDATE_ROLE_QUERY, [role, user_id], (err, result) => {
    if (err) {
      console.error("❌ Error updating role:", err);
      return res.status(500).json({ error: "Failed to update role" });
    }

    res.status(200).json({ message: "Role updated successfully" });
  });
});

app.get(GET_USERS, (req, res) => {
  db.query(process.env.GET_USERS_QUERY, (err, results) => {
    if (err) {
      console.error("❌ Error fetching users:", err);
      return res.status(500).json({ error: "Failed to retrieve users" });
    }
    res.status(200).json({ users: results });
  });
});

app.delete(DELETE_USER, (req, res) => {
  const userId = req.params.userId;

  if (!userId) {
    return res.status(400).json({ error: "User ID is required" });
  }

  // First, delete from user_roles
  db.query(process.env.DELETE_USER_ROLE_QUERY, [userId], (err, roleResult) => {
    if (err) {
      console.error("❌ Error deleting from user_roles:", err);
      return res.status(500).json({ error: "Failed to delete user role" });
    }

    // Then, delete from users_credentials
    db.query(process.env.DELETE_USER_QUERY, [userId], (err, userResult) => {
      if (err) {
        console.error("❌ Error deleting from users_credentials:", err);
        return res.status(500).json({ error: "Failed to delete user" });
      }

      console.log(`✅ User with ID ${userId} deleted successfully.`);
      res.status(200).json({ message: "User deleted successfully" });
    });
  });
});

// Function: Send Email with Database Data
async function sendDatabaseEmail() {
  db.query(process.env.SELECT_USERS_QUERY, (err, users) => {
    if (err) {
      console.error("❌ Error fetching users:", err);
      return;
    }

    db.query(process.env.SELECT_ANSWERS_QUERY, (err, answers) => {
      if (err) {
        console.error("❌ Error fetching answers:", err);
        return;
      }

      let emailBody = "📊 **User Stats**:\n\n";
      users.forEach((user) => {
        emailBody += `👤 ${user.name} - ${user.questions_answered} questions answered\n`;
      });

      emailBody += "\n📝 **Answered Questions**:\n\n";
      answers.forEach((answer) => {
        emailBody += `❓ ${answer.question} (by User ID: ${answer.user_id} at ${answer.answered_at})\n`;
      });

      let transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASSWORD,
        },
      });

      let mailOptions = {
        from: process.env.EMAIL_USER,
        to: process.env.EMAIL_RECIPIENT,
        subject: "Monthly Question Stats Report",
        text: emailBody,
      };

      transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
          console.error("❌ Error sending email:", error);
        } else {
          console.log("📧 Email sent:", info.response);
          clearDatabaseTables();
        }
      });
    });
  });
}

// Function: Clear Tables After Sending Email
function clearDatabaseTables() {
  db.query(process.env.DELETE_ANSWERS_QUERY, (err, result) => {
    if (err) {
      console.error("❌ Error clearing Answers table:", err);
      return;
    }
    console.log("✅ Answers table cleared.");

    db.query(process.env.UPDATE_USERS_QUERY, (err, result) => {
      if (err) {
        console.error("❌ Error resetting Users table:", err);
        return;
      }
      console.log("✅ Users table reset.");
    });
  });
}

// Schedule: Run on the 1st day of every month at 8 AM
cron.schedule("0 8 1 * *", () => {
  console.log("⏳ Running scheduled task: Sending monthly report...");
  sendDatabaseEmail();
});

// Route: Trigger Report Manually
app.get(SEND_REPORT, (req, res) => {
  sendDatabaseEmail();
  res.status(200).json({ message: "Email is being sent..." });
});

// Start the server
const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});