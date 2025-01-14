﻿
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using TutorMe.Data;
using TutorMe.Entities;
using TutorMe.Models;
using TutorMe.Services;

namespace TutorMe.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerBase {
        private readonly IJwtService _jwtService;
        private readonly TutorMeContext _context;

        public AccountController(IJwtService jwtService, TutorMeContext context) {
            _jwtService = jwtService;
            _context = context;
        }
        
        /// <summary> Logs in the user </summary>
        /// <param name="authRequest">UserLogIn object(check entities)</param>
        /// <returns>The user object and the tokens</returns>
        [HttpPost("[action]")]
        public async Task<IActionResult> AuthToken([FromBody] UserLogIn authRequest) {
            if (!ModelState.IsValid) {
                return BadRequest(new AuthResponse { IsSuccess = false, Reason = "UserName and Password must be provided." });
            }

            string ipAddress = "";
            if(HttpContext==null || HttpContext.Connection==null || HttpContext.Connection.RemoteIpAddress==null) {
                ipAddress = "::1";//for testing purposes
            } else {
                ipAddress = HttpContext.Connection.RemoteIpAddress.ToString();
            }
            var authResponse = await _jwtService.GetTokenAsync(authRequest, ipAddress);
            if (authResponse == null)
                return Unauthorized();
            var user = _context.User.FirstOrDefault(e => e.Email == authRequest.Email);
            return Ok(new {
                token = authResponse.Token,
                refreshToken = authResponse.RefreshToken,
                user = user
            });
        }

        /// <summary> Refreshes an expired token </summary>
        /// <param name="request"> RefreshTokenRequest object(check entities)</param>
        /// <returns>returns refreshed token</returns>
        [HttpPost("[action]")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request) {
            if (!ModelState.IsValid)
                return BadRequest(new AuthResponse { IsSuccess = false, Reason = "Tokens must be provided" });
            string ipAddress = "";
            if(HttpContext==null || HttpContext.Connection==null || HttpContext.Connection.RemoteIpAddress==null) {
                ipAddress = "::1";//for testing purposes
            } else {
                ipAddress = HttpContext.Connection.RemoteIpAddress.ToString();
            }
            var token = GetJwtToken(request.ExpiredToken);
            var userRefreshToken = _context.UserRefreshToken.FirstOrDefault(
                x => x.IsInvalidated == false && x.Token == request.ExpiredToken
                && x.RefreshToken == request.RefreshToken
                && x.IpAddress == ipAddress);

            AuthResponse response = ValidateDetails(token, userRefreshToken);
            if (!response.IsSuccess)
                return BadRequest(response);

            userRefreshToken.IsInvalidated = true;
            _context.UserRefreshToken.Update(userRefreshToken);
            await _context.SaveChangesAsync();

            var userName = token.Claims.FirstOrDefault(x => x.Type == JwtRegisteredClaimNames.NameId).Value;
            var authResponse = await _jwtService.GetRefreshTokenAsync(ipAddress, userRefreshToken.UserId,
                userName);

            return Ok(authResponse);
        }

        /// <summary> Validate the user details </summary>
        /// <param name="token">The </param>
        /// <param name="userRefreshToken"></param>
        /// <returns>returns a token and the refresh token</returns>
        private AuthResponse ValidateDetails(JwtSecurityToken token, Models.UserRefreshToken userRefreshToken) {
            if (userRefreshToken == null)
                return new AuthResponse { IsSuccess = false, Reason = "Invalid Token Details." };
            if (token.ValidTo > DateTime.UtcNow)
                return new AuthResponse { IsSuccess = false, Reason = "Token not expired." };
            if (!userRefreshToken.IsActive)
                return new AuthResponse { IsSuccess = false, Reason = "Refresh Token Expired" };
            return new AuthResponse { IsSuccess = true };
        }

        /// <summary> Generate a token from an expired token </summary>
        /// <param name="expiredToken"></param>
        /// <returns>A token</returns>
        private JwtSecurityToken GetJwtToken(string expiredToken) {
            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();
            return tokenHandler.ReadJwtToken(expiredToken);
        }
    }
}
