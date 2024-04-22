namespace RV32Semu;

class Matrix4x4
{
    float m00, m01, m02, m03;
    float m10, m11, m12, m13;
    float m20, m21, m22, m23;
    float m30, m31, m32, m33;

    public Matrix4x4()
    {
        m00 = m01 = m02 = m03 = 0;
        m10 = m11 = m12 = m13 = 0;
        m20 = m21 = m22 = m23 = 0;
        m30 = m31 = m32 = m33 = 0;
    }

    public Matrix4x4(Func<uint, uint, float> generator)
    {
        m00 = generator(0, 0); m01 = generator(0, 1); m02 = generator(0, 2); m03 = generator(0, 3);
        m10 = generator(1, 0); m11 = generator(1, 1); m12 = generator(1, 2); m13 = generator(1, 3);
        m20 = generator(2, 0); m21 = generator(2, 1); m22 = generator(2, 2); m23 = generator(2, 3);
        m30 = generator(3, 0); m31 = generator(3, 1); m32 = generator(3, 2); m33 = generator(3, 3);
    }
    public Matrix4x4 SwapCol(uint i, uint j)
    {
        Matrix4x4 that = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                that[row, col] = this[row, col];
            }
            that[row, i] = this[row, j];
            that[row, j] = this[row, i];
        }
        return that;
    }
    public Matrix4x4 SwapRow(uint i, uint j)
    {
        Matrix4x4 that = new();
        for (uint col = 0; col < 4; col++)
        {
            for (uint row = 0; row < 4; row++)
            {
                that[row, col] = this[row, col];
            }
            that[i, col] = this[j, col];
            that[j, col] = this[i, col];
        }
        return that;
    }
    public Matrix4x4 MultiplyCol(float x, uint i)
    {
        Matrix4x4 that = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                that[row, col] = col == i ? (x * this[row, col]) : this[row, col];
            }
        }
        return that;
    }
    public Matrix4x4 MultiplyRow(float x, uint i)
    {
        Matrix4x4 that = new();
        for (uint col = 0; col < 4; col++)
        {
            for (uint row = 0; row < 4; row++)
            {
                that[row, col] = row == i ? (x * this[row, col]) : this[row, col];
            }
        }
        return that;
    }

    public Matrix4x4 AdditionCol(float x, uint i, uint j)
    {
        Matrix4x4 that = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                that[row, col] = col == j ? (x * this[row, i] + this[row, j]) : this[row, col];
            }
        }
        return that;
    }
    public Matrix4x4 AdditionRow(float x, uint i, uint j)
    {
        Matrix4x4 that = new();
        for (uint col = 0; col < 4; col++)
        {
            for (uint row = 0; row < 4; row++)
            {
                that[row, col] = row == j ? (x * this[i, col] + this[row, col]) : this[row, col];
            }
        }
        return that;
    }
    public Matrix4x4 Transpose
    {
        get
        {
            Matrix4x4 that = new();
            for (uint row = 0; row < 4; row++)
            {
                for (uint col = 0; col < 4; col++)
                {
                    that[row, col] = this[col, row];
                }
            }
            return that;
        }
    }

    public static Matrix4x4 operator +(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] + b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator -(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] - b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator *(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] * b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator /(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (uint row = 0; row < 4; row++)
        {
            for (uint col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] / b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator %(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 result = new();
        for (uint i = 0; i < 4; i++)
        {
            for (uint j = 0; j < 4; j++)
            {
                for (uint k = 0; k < 4; k++)
                {
                    result[i, j] += a[i, k] * b[k, j];
                }
            }
        }
        return result;
    }

    public float Trace => m00 + m11 + m22 + m33;
    public float Determinant => m00 * m11 * m22 * m33
                                - m00 * m11 * m23 * m32
                                - m00 * m12 * m21 * m33
                                + m00 * m12 * m23 * m31
                                + m00 * m13 * m21 * m32
                                - m00 * m13 * m22 * m31
                                - m01 * m10 * m22 * m33
                                + m01 * m10 * m23 * m32
                                + m01 * m12 * m20 * m33
                                - m01 * m12 * m23 * m30
                                - m01 * m13 * m20 * m32
                                + m01 * m13 * m22 * m30
                                + m02 * m10 * m21 * m33
                                - m02 * m10 * m23 * m31
                                - m02 * m11 * m20 * m33
                                + m02 * m11 * m23 * m30
                                + m02 * m13 * m20 * m31
                                - m02 * m13 * m21 * m30
                                - m03 * m10 * m21 * m32
                                + m03 * m10 * m22 * m31
                                + m03 * m11 * m20 * m32
                                - m03 * m11 * m22 * m30
                                - m03 * m12 * m20 * m31
                                + m03 * m12 * m21 * m30;
    public float this[uint i, uint j]
    {
        get => (i, j) switch
        {
            (0, 0) => m00,
            (0, 1) => m01,
            (0, 2) => m02,
            (0, 3) => m03,
            (1, 0) => m10,
            (1, 1) => m11,
            (1, 2) => m12,
            (1, 3) => m13,
            (2, 0) => m20,
            (2, 1) => m21,
            (2, 2) => m22,
            (2, 3) => m23,
            (3, 0) => m30,
            (3, 1) => m31,
            (3, 2) => m32,
            (3, 3) => m33,
            _ => throw new IndexOutOfRangeException("Index out of range.")
        };
        set
        {
            switch (i, j)
            {
                case (0, 0):
                    m00 = value;
                    break;
                case (0, 1):
                    m01 = value;
                    break;
                case (0, 2):
                    m02 = value;
                    break;
                case (0, 3):
                    m03 = value;
                    break;
                case (1, 0):
                    m10 = value;
                    break;
                case (1, 1):
                    m11 = value;
                    break;
                case (1, 2):
                    m12 = value;
                    break;
                case (1, 3):
                    m13 = value;
                    break;
                case (2, 0):
                    m20 = value;
                    break;
                case (2, 1):
                    m21 = value;
                    break;
                case (2, 2):
                    m22 = value;
                    break;
                case (2, 3):
                    m23 = value;
                    break;
                case (3, 0):
                    m30 = value;
                    break;
                case (3, 1):
                    m31 = value;
                    break;
                case (3, 2):
                    m32 = value;
                    break;
                case (3, 3):
                    m33 = value;
                    break;
                default:
                    throw new IndexOutOfRangeException("Index out of range.");
            }
        }
    }
    public void ForEach(Action<uint, uint, float> action)
    {
        action(0, 0, m00); action(0, 1, m01); action(0, 2, m02); action(0, 3, m03);
        action(1, 0, m10); action(1, 1, m11); action(1, 2, m12); action(1, 3, m13);
        action(2, 0, m20); action(2, 1, m21); action(2, 2, m22); action(2, 3, m23);
        action(3, 0, m30); action(3, 1, m31); action(3, 2, m32); action(3, 3, m33);
    }
}