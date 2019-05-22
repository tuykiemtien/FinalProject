using FinalProjectAPI.Entites.Entity;
using FinalProjectAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FinalProjectAPI.Business
{
	public class UserBusiness
	{
		private UserRepository userRepository;
		public UserBusiness()
		{
			userRepository = new UserRepository();
		} 
		public User GetUserByEmail(string email)
		{
			try
			{
				return userRepository.GetUserByEmail(email);
			}
			catch(Exception e)
			{
				return new User();
			}
		}
	}
}