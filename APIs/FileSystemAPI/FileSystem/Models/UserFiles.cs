﻿using System;
using System.Collections.Generic;

namespace FileSystem.Models {
    public partial class UserFiles {
        public Guid Id { get; set; }
        public byte[] UserImage { get; set; }
        public byte[] UserTranscript { get; set; }
    }
}