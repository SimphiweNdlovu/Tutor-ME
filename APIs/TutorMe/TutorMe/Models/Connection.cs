﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace TutorMe.Models
{
    public partial class Connection
    {
        public Guid ConnectionId { get; set; }
        public Guid TutorId { get; set; }
        public Guid TuteeId { get; set; }
        public Guid ModuleId { get; set; }
        public Guid? TuteeUserId { get; set; }

        [JsonIgnore]
        public virtual Module Module { get; set; }
        [JsonIgnore]
        public virtual User Tutee { get; set; }
        [JsonIgnore]
        public virtual User Tutor { get; set; }
    }
}