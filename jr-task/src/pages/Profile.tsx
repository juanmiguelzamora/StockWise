import users from "../ex_data/user.json";

export default function Profile() {
    // Simulate admin login by selecting the admin user
    const adminUser = users.find(user => user.user_role === "admin");

    return (
        <>
            <div>
                <div>
                    <img src="skdjsj" alt="Profile Picture" />
                    <h2>{adminUser ? adminUser.username : "Unknown User"}</h2>
                    <p>{adminUser ? adminUser.user_role : "No Role"}</p>
                </div>
                <div>
                    <div>
                        <h2>Personal Information</h2>
                        <button>Edit</button>
                        <button>Change Password</button>
                    </div>
                    <div>
                        <p>Username: {adminUser ? adminUser.username : ""}</p>
                        <p>Email: {adminUser ? adminUser.email : ""}</p>
                        <p>User Role: {adminUser ? adminUser.user_role : ""}</p>
                        
                        <hr />

                        <div>
                            <h4>Username</h4>
                            <h4>Email</h4>
                            <h4>User Role</h4>
                        </div>

                        {adminUser && (
                            <div>
                                <p>{adminUser.username}</p>
                                <p>{adminUser.email}</p>
                                <p>{adminUser.user_role}</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
}