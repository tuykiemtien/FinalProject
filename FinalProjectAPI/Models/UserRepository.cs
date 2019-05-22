using FinalProjectAPI.Common;
using FinalProjectAPI.Constant;
using FinalProjectAPI.Entites.CommonEntites;
using FinalProjectAPI.Entites.Entity;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace FinalProjectAPI.Models
{
	public class UserRepository : CommonRepository<User>
	{
		public User GetUserByEmail(string email)
		{
			try
			{
				var response = GetByStoredProcedure<User>(StoreProd.GetUserByEmail,
									new StoredProcedureParameter("Email", email, DbType.String));
				return response != null && response.Count > 0 ? response.FirstOrDefault() : new User();
			}
			catch(Exception e)
			{
				return new User();
			}
		}
	}
}