using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FinalProjectAPI.Entites.Entity
{
	public class User
	{
		public long UserId { get; set; }
		public string Username { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public DateTime CreatedDate { get; set; }
		public DateTime UpdatedDate { get; set; }
		public DateTime DoB { get; set; }
		public string Email { get; set; }
		public string PhoneNumber { get; set; }

	}
}